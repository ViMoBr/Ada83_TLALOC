#!/usr/bin/env python3
"""
Analyseur de spécification DIANA pour le compilateur TLALOC
Objectif : Identifier systématiquement tous les nœuds DIANA à traiter dans l'EXPANDER
"""

import re
from collections import defaultdict, OrderedDict
from typing import Dict, List, Set, Tuple

class DianaAnalyzer:
    def __init__(self):
        self.classes = {}  # class_name -> parent_chain
        self.nodes = {}    # node_name -> attributes
        self.hierarchy = defaultdict(list)  # parent -> [children]
        self.all_node_types = set()
        
    def parse_classes(self, filename):
        """Parse diana_CLASS_.txt to build class hierarchy"""
        print(f"Parsing class hierarchy from {filename}...")
        with open(filename, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                    
                # Format: ROOT > PARENT1 > PARENT2 > ... > NODE
                parts = [p.strip() for p in line.split('>')]
                if len(parts) < 2:
                    continue
                    
                node = parts[-1]
                parents = parts[:-1]
                self.classes[node] = parents
                
                # Build hierarchy
                for i in range(len(parts)-1):
                    parent = parts[i]
                    child = parts[i+1]
                    if child not in self.hierarchy[parent]:
                        self.hierarchy[parent].append(child)
                        
        print(f"  Found {len(self.classes)} node types")
        return self
        
    def parse_nodes(self, filename):
        """Parse diana_NODES.txt to get node attributes"""
        print(f"Parsing node attributes from {filename}...")
        with open(filename, 'r') as f:
            current_node = None
            current_attrs = []
            
            for line in f:
                line = line.strip()
                if not line:
                    continue
                    
                # New node definition: "node_name =>"
                if line.endswith('=>'):
                    if current_node:
                        self.nodes[current_node] = current_attrs
                    current_node = line[:-2].strip()
                    current_attrs = []
                    self.all_node_types.add(current_node)
                    
                # End of node: ";"
                elif line == ';':
                    if current_node:
                        self.nodes[current_node] = current_attrs
                        current_node = None
                        current_attrs = []
                        
                # Attribute: "=> attr_name : type"
                elif line.startswith('=>'):
                    attr_line = line[2:].strip()
                    if ':' in attr_line:
                        attr_name, attr_type = attr_line.split(':', 1)
                        current_attrs.append({
                            'name': attr_name.strip(),
                            'type': attr_type.strip()
                        })
                        
            # Last node
            if current_node:
                self.nodes[current_node] = current_attrs
                
        print(f"  Found {len(self.nodes)} nodes with attributes")
        return self
        
    def get_all_children(self, class_name, recursive=True):
        """Get all children of a class (recursively if requested)"""
        children = self.hierarchy.get(class_name, [])
        if not recursive:
            return children
            
        all_children = set(children)
        for child in children:
            all_children.update(self.get_all_children(child, recursive=True))
        return sorted(all_children)
        
    def get_concrete_nodes(self, class_name):
        """Get all concrete (leaf) nodes descending from a class"""
        concrete = set()
        
        def visit(node):
            children = self.hierarchy.get(node, [])
            if not children:
                # Leaf node - concrete
                concrete.add(node)
            else:
                for child in children:
                    visit(child)
                    
        visit(class_name)
        return sorted(concrete)
        
    def analyze_expander_coverage(self, abstract_classes):
        """
        Pour chaque classe abstraite (EXP, STM, DECL, etc.),
        identifier tous les nœuds concrets à traiter
        """
        print("\n" + "="*80)
        print("ANALYSIS: Required node handlers for EXPANDER")
        print("="*80)
        
        coverage = {}
        for class_name in abstract_classes:
            concrete = self.get_concrete_nodes(class_name)
            coverage[class_name] = concrete
            
            print(f"\n{class_name} -> {len(concrete)} concrete nodes:")
            for i, node in enumerate(concrete, 1):
                attrs = self.nodes.get(node, [])
                print(f"  {i:3d}. {node:30s} ({len(attrs)} attributes)")
                
        return coverage
        
    def print_hierarchy(self, root, indent=0, max_depth=5):
        """Print class hierarchy tree"""
        if indent > max_depth:
            return
            
        children = self.hierarchy.get(root, [])
        print("  " * indent + f"+ {root} ({len(children)} children)")
        
        for child in children:
            self.print_hierarchy(child, indent+1, max_depth)
            
    def generate_skeleton_code(self, class_name, output_file):
        """Generate Ada skeleton code for handling all nodes of a class"""
        concrete = self.get_concrete_nodes(class_name)
        
        with open(output_file, 'w') as f:
            f.write(f"-- Generated skeleton for {class_name}\n")
            f.write(f"-- Total concrete nodes: {len(concrete)}\n\n")
            
            f.write(f"procedure Process_{class_name} (Node : DIANA.Node) is\n")
            f.write(f"  Node_Class : constant DIANA.Class := Get_Class(Node);\n")
            f.write(f"begin\n")
            f.write(f"  case Node_Class is\n")
            
            for node in concrete:
                attrs = self.nodes.get(node, [])
                f.write(f"\n    when {node} =>\n")
                f.write(f"      -- TODO: Handle {node}\n")
                for attr in attrs:
                    f.write(f"      -- Attribute: {attr['name']} : {attr['type']}\n")
                f.write(f"      null; -- TODO: Implement\n")
                
            f.write(f"\n    when others =>\n")
            f.write(f"      raise Program_Error with \"Unexpected {class_name} node: \" & Node_Class'Image;\n")
            f.write(f"  end case;\n")
            f.write(f"end Process_{class_name};\n")
            
        print(f"\nGenerated skeleton code in: {output_file}")


def main():
    analyzer = DianaAnalyzer()
    
    # Parse DIANA specification files
    analyzer.parse_classes('/mnt/project/diana_CLASS_.txt')
    analyzer.parse_nodes('/mnt/project/diana_NODES.txt')
    
    # Important abstract classes for EXPANDER
    important_classes = [
        'EXP',           # Expressions
        'STM',           # Statements
        'DECL',          # Declarations
        'TYPE_DEF',      # Type definitions
        'TYPE_SPEC',     # Type specifications
        'NAME',          # Names
        'CONSTRAINT',    # Constraints
    ]
    
    # Analyze coverage
    coverage = analyzer.analyze_expander_coverage(important_classes)
    
    # Show hierarchy for key classes
    print("\n" + "="*80)
    print("CLASS HIERARCHIES")
    print("="*80)
    for class_name in ['ALL_SOURCE', 'TYPE_SPEC', 'EXP', 'STM']:
        print(f"\n{class_name}:")
        analyzer.print_hierarchy(class_name, indent=0, max_depth=3)
    
    # Generate skeleton files
    print("\n" + "="*80)
    print("GENERATING SKELETON CODE")
    print("="*80)
    for class_name in important_classes:
        output_file = f"/home/claude/skeleton_{class_name.lower()}.txt"
        analyzer.generate_skeleton_code(class_name, output_file)
    
    # Summary statistics
    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    print(f"Total node types: {len(analyzer.all_node_types)}")
    print(f"Total classes: {len(analyzer.classes)}")
    print(f"Nodes with attributes: {len(analyzer.nodes)}")
    
    for class_name, concrete in coverage.items():
        print(f"{class_name:20s} : {len(concrete):3d} concrete nodes to handle")


if __name__ == '__main__':
    main()
