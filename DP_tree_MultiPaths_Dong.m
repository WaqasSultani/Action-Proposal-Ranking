function [nodes_selected path_weights] = DP_tree_MultiPaths_Dong(tree_structure,unary_weights,binary_weights,number_of_paths)
    %% Input definitions:
    % tree_structure{*}.parent_index, child_indexes
    for path_index=1:number_of_paths
        [nodes_selected(path_index,:) path_weights(path_index,1)] = DP_tree_Dong(tree_structure,unary_weights,binary_weights);
        for node_index=1:size(nodes_selected,2)
            unary_weights{node_index}(nodes_selected(path_index,node_index)) = NaN;
        end
    end
end
