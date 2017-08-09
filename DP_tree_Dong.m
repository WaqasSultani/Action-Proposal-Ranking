function [nodes_selected path_weight] = DP_tree_Dong(tree_structure,unary_weights,binary_weights)
    %% Input definitions:
    % tree_structure{*}.parent_index, child_indexes
    %% Test case
    if nargin==0
        unary_weights{1} = [1 2]';
        unary_weights{2} = [2 3 2]';
        unary_weights{3} = [2 3]';
        binary_weights{1}{1} = [0 0 0; 2 0 0];
        binary_weights{2}{1} = [0 0; 10 0; 0 0];
        tree_structure{1}.child_indexes = [2];
        tree_structure{1}.parent_index = [];
        tree_structure{2}.child_indexes = [3];
        tree_structure{2}.parent_index = 1;
        tree_structure{3}.child_indexes = [];
        tree_structure{3}.parent_index = 2; 
        nodes_selected = DP_tree_Dong(tree_structure,unary_weights,binary_weights);
    end
    max_map = {};
    max_map_backtrack = {};
    node_processing_vector = zeros(1,length(tree_structure));
    active_nodes = [];
    for node_index=1:length(tree_structure)
        if length(tree_structure{node_index}.child_indexes)<=0
            active_nodes = [active_nodes node_index];
        end
    end
    while length(active_nodes)>0
        for active_node_index=1:length(active_nodes)
            current_active_node = active_nodes(active_node_index);
            current_child_indexes = tree_structure{current_active_node}.child_indexes;
            max_map{current_active_node} = unary_weights{current_active_node};
            for child_index=1:length(current_child_indexes)
                current_child_node_index = current_child_indexes(child_index);
                augmented_binary_weight_current = binary_weights{current_active_node}{child_index}...
                    + repmat(max_map{current_child_node_index}',[size(binary_weights{current_active_node}{child_index},1) 1]);
                max_values = NaN*ones(1,size(augmented_binary_weight_current,1));
                max_indexes = NaN*ones(1,size(augmented_binary_weight_current,1));
                for max_i=1:size(augmented_binary_weight_current,1)
                    [max_values(max_i) max_indexes(max_i)] = max(augmented_binary_weight_current(max_i,:));
                end
                max_map{current_active_node} = max_map{current_active_node} + max_values';
                max_map_backtrack{current_active_node}{child_index} = max_indexes';
            end
            node_processing_vector(current_active_node) = 1;
        end
        active_nodes = [];
        for node_index=1:length(tree_structure)
            all_child_nodes_processed = 1;
            child_nodes = tree_structure{node_index}.child_indexes;
            if length(child_nodes)>0
                for child_index=1:length(child_nodes)
                    if node_processing_vector(child_nodes(child_index))==0
                        all_child_nodes_processed = 0;
                    end
                end
            end
            if (all_child_nodes_processed==1)&&(node_processing_vector(node_index)==0)
                active_nodes = [active_nodes node_index];
            end
        end
    end
    
    %% Backtrack
    active_nodes = [1];
    nodes_selected = [];
    while length(active_nodes)>0
        active_nodes_new = [];
        if (length(active_nodes)==1)&&(active_nodes(1)==1)
            [path_weight,max_index] = max(max_map{1});
            nodes_selected(1) = max_index;
            nodes_selected(2) = max_map_backtrack{1}{1}(max_index);
            active_nodes_new = tree_structure{1}.child_indexes;
        else
            for active_node_index=1:length(active_nodes)
                current_node_index = active_nodes(active_node_index);
                child_indexes = tree_structure{current_node_index}.child_indexes;
                for child_indexes_index=1:length(child_indexes)
                    child_node_index = child_indexes(child_indexes_index);
                    nodes_selected(child_node_index) = max_map_backtrack{current_node_index}{child_indexes_index}(nodes_selected(current_node_index));
                    active_nodes_new = [active_nodes_new child_indexes];
                end
            end
        end
        active_nodes = active_nodes_new;
    end
end
