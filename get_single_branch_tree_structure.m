function tree_structure = get_single_branch_tree_structure(node_number)
    tree_structure = cell(1,node_number);
    for node_index=1:node_number
        if node_index<node_number
            tree_structure{node_index}.child_indexes = node_index+1;
        else
            tree_structure{node_index}.child_indexes = [];
        end
        if node_index>1
            tree_structure{node_index}.parent_index = node_index - 1;
        else
            tree_structure{node_index}.parent_index = [];
        end
    end
end