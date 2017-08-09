function [nodes_selected path_weight] = DP_branch_MultiPaths_Dong(unary_weights_matrix,binary_weights_matrix,number_of_paths)
    %% Input definitions:
    % 
    node_number = size(unary_weights_matrix,2);
    unary_weights = cell(1,node_number);
    binary_weights = cell(1,node_number-1);
    for node_index=1:node_number
        current_unary_weights = unary_weights_matrix(:,node_index);
        unary_weights{node_index} = current_unary_weights(~isnan(current_unary_weights));
    end
    for node_index=1:node_number-1
        binary_weights{node_index}{1} = binary_weights_matrix(1:length(unary_weights{node_index}),1:length(unary_weights{node_index+1}),node_index);
    end
    tree_structure = cell(1,node_number);
    for node_index=1:node_number
        if node_index>1
            tree_structure{node_index}.parent_index = node_index-1;
        else
            tree_structure{node_index}.parent_index = [];
        end
        if node_index<node_number
            tree_structure{node_index}.child_indexes = node_index+1;
        else
            tree_structure{node_index}.child_indexes = [];
        end
    end
    [nodes_selected, path_weight] = DP_tree_MultiPaths_Dong(tree_structure,unary_weights,binary_weights,number_of_paths);

end
