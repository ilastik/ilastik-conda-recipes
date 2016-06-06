import os
import json
import argparse
import pydot

def dict_to_dot_file( deps_dict, output_filepath ):
    g = pydot.Dot('dependencies', graph_type='digraph')

    for pkg_name, dep_list in deps_dict.items():
        g.add_node( pydot.Node(pkg_name) )
        for dep in dep_list:
            g.add_edge( pydot.Edge(pkg_name, dep.split(' ')[0]) )

    g.write_dot(output_filepath)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input_json')
    parser.add_argument('--output_path', '-o')
    args = parser.parse_args()
    
    output_path = args.output_path or os.path.splitext(args.input_json)[0] + '.dot'

    with open(args.input_json, 'r') as f:
        deps_dict = json.load(f)
    
    assert isinstance( deps_dict, dict ), "Input json is not in graph form"
    for k,v in deps_dict.items():
        assert isinstance(v, list), "Input json is not in graph form"

    dict_to_dot_file(deps_dict, output_path)

if __name__ == "__main__":
    import sys
    sys.exit( main() )
