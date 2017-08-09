function overlapRatio = bboxOverlapRatio_w(varargin)
%bboxOverlapRatio Compute bounding box overlap ratio.
%  overlapRatio = bboxOverlapRatio(bboxA, bboxB) returns the overlap ratio
%  between each pair of bounding boxes contained in bboxA and bboxB. Each
%  row of bboxA and bboxB is a [x y width height] vector, where x and y are
%  an upper left corner of a bounding box. If bboxA is an M-by-4 matrix and
%  bboxB is an N-by-4 matrix, overlapRatio is an M-by-N matrix, with the
%  (I,J) entry equal to the overlap ratio between row I in bboxA and row J
%  in bboxB. By default, the overlap ratio between two boxes A and B is
%  defined as area(A intersect B) / area(A union B). The range of
%  overlapRatio is between 0 and 1, where 1 implies a perfect overlap.
%
%  overlapRatio = bboxOverlapRatio(bboxA, bboxB, ratioType) additionally
%  lets you specify the method to compute the ratio. ratioType can be
%  'Union', as described above, or 'Min'. When ratioType is 'Min', the
%  overlap ratio is defined as area(A intersect B) / min(area(A),area(B)).
%
%  Class Support 
%  ------------- 
%  bboxA and bboxB are real, finite, and nonsparse. They can be uint8,
%  int8, uint16, int16, uint32, int32, single and double. The output
%  overlapRatio is double if bboxA or bboxB is double, otherwise it is
%  single.
%
%  Example 1 - compute the overlap ratio between two bounding boxes
%  ----------  
%   % define two bounding boxes
%   bboxA = [1, 1, 100, 200]; 
%   bboxB = bboxA + 20;
%
%   % compute the overlap ratio between the two bounding boxes
%   overlapRatio = bboxOverlapRatio(bboxA, bboxB)
%
%  Example 2 - compute the overlap ratio between every pair of bounding boxes
%  ----------  
%   % randomly generate two sets of bounding boxes
%   bboxA = 10*rand(5, 4); 
%   bboxB = 10*rand(10, 4);
%
%   % make sure the width and height are strictly positive
%   bboxA(:,3:4) = bboxA(:,3:4) + 10;
%   bboxB(:,3:4) = bboxB(:,3:4) + 10;
%
%   % compute the overlap ratio between every pair
%   overlapRatio = bboxOverlapRatio(bboxA, bboxB)
%
%  See also selectStrongestBbox 

%  Copyright 2013-2014 The MathWorks, Inc.

%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

isUsingCodeGeneration = ~isempty(coder.target);

% Parse and check inputs
if isUsingCodeGeneration,
    [bboxA, bboxB, ratioType] = validateAndParseInputsCodegen(varargin{:});
else
    [bboxA, bboxB, ratioType] = validateAndParseInputs(varargin{:});    
end

if (isa(bboxA,'double') || isa(bboxB,'double'))
    bboxA = double(bboxA);
    bboxB = double(bboxB);
else
    bboxA = single(bboxA);
    bboxB = single(bboxB);    
end

if (isempty(bboxA) || isempty(bboxB))
    overlapRatio = zeros(size(bboxA, 1), size(bboxB, 1), 'like', bboxA);
    return;
end

if isUsingCodeGeneration,
    overlapRatio = bboxOverlapRatioCodegen(bboxA, bboxB, ratioType);
else
    if strncmpi(ratioType, 'Union', 1)
        overlapRatio = visionBboxIntersectByUnion(bboxA, bboxB);
    else
        overlapRatio = visionBboxIntersectByMin(bboxA, bboxB);
    end
end
end

%==========================================================================
function checkInputBoxes(bbox)
% Validate the input boxes

validateattributes(bbox,{'uint8', 'int8', 'uint16', 'int16', 'uint32', ...
    'int32', 'single', 'double'}, {'real','nonsparse','finite','size',[NaN, 4]}, ...
    mfilename);

if (any(bbox(:,3)<=0) || any(bbox(:,4)<=0))
    error(message('vision:visionlib:invalidBboxHeightWidth'));
end
end

%========================================================================== 
function checkRatioType(value)
% Validate the input ratioType string

list = {'Union', 'Min'};
validateattributes(value, {'char'}, {'nonempty'}, mfilename, 'RatioType');

validatestring(value, list, mfilename, 'RatioType');
end

%==========================================================================
function [bboxA, bboxB, ratioType] = validateAndParseInputs(varargin)
% Validate and parse optional inputs

% Setup parser
parser = inputParser;
parser.CaseSensitive = false;
parser.FunctionName  = mfilename;

parser.addRequired('bboxA', @checkInputBoxes);
parser.addRequired('bboxB', @checkInputBoxes);
parser.addOptional('RatioType', 'Union', @checkRatioType);

% Parse input
parser.parse(varargin{:});

bboxA = parser.Results.bboxA;
bboxB = parser.Results.bboxB;
ratioType = parser.Results.RatioType;
            
end

%==========================================================================
function checkInputBoxesCodegen(bbox)
% Validate the input boxes

validateattributes(bbox,{'uint8', 'int8', 'uint16', 'int16', 'uint32', ...
    'int32', 'single', 'double'}, {'real','nonsparse','finite','size',[NaN, 4]}, ...
    mfilename);

coder.internal.errorIf((any(bbox(:,3)<=0) || any(bbox(:,4)<=0)), ...
                        'vision:visionlib:invalidBboxHeightWidth');
end

%==========================================================================
function [bboxA, bboxB, ratioType] = validateAndParseInputsCodegen(varargin)
% Validate and parse optional inputs

eml_lib_assert(nargin >= 2, 'vision:visionlib:NotEnoughArgs', 'Not enough input arguments');
eml_lib_assert(nargin <= 3, 'vision:visionlib:TooManyArgs', 'Too many input arguments.');

bboxA = varargin{1};
checkInputBoxesCodegen(bboxA);

bboxB = varargin{2};
checkInputBoxesCodegen(bboxB);

if nargin == 3,
    ratioType = varargin{3};
    validateattributes(ratioType, {'char'}, {'nonempty'}, mfilename, 'ratioType');
    validatestring(ratioType, {'Union', 'Min'}, mfilename, 'ratioType');
else
    ratioType = 'Union';
end

end

%========================================================================== 
function overlapRatio = bboxOverlapRatioCodegen(bboxA, bboxB, ratioType)
% Compute the overlap ratio between every row in bboxA and bboxB

% left top corner
x1BboxA = bboxA(:, 1);
y1BboxA = bboxA(:, 2);
% right bottom corner
x2BboxA = x1BboxA + bboxA(:, 3);
y2BboxA = y1BboxA + bboxA(:, 4);

x1BboxB = bboxB(:, 1);
y1BboxB = bboxB(:, 2);
x2BboxB = x1BboxB + bboxB(:, 3);
y2BboxB = y1BboxB + bboxB(:, 4);

% area of the bounding box
areaA = bboxA(:, 3) .* bboxA(:, 4);
areaB = bboxB(:, 3) .* bboxB(:, 4);

overlapRatio = zeros(size(bboxA,1),size(bboxB,1), 'like', bboxA);

for m = 1:size(bboxA,1)
    for n = 1:size(bboxB,1)
        % compute the corners of the intersect
        x1 = max(x1BboxA(m), x1BboxB(n));
        y1 = max(y1BboxA(m), y1BboxB(n));
        x2 = min(x2BboxA(m), x2BboxB(n));
        y2 = min(y2BboxA(m), y2BboxB(n));

        % skip if there is no intersection
        w = x2 - x1;
        if w <= 0
            continue;
        end
        
        h = y2 - y1;
        if h <= 0
            continue;
        end
        
        intersectAB = w * h;
        if strncmpi(ratioType, 'Union', 1) % divide by union of bboxA and bboxB
            overlapRatio(m,n) = intersectAB/(areaA(m)+areaB(n)-intersectAB);
        else % divide by minimum of bboxA and bboxB
            overlapRatio(m,n) = intersectAB/min(areaA(m), areaB(n));
        end
    end
end

end
