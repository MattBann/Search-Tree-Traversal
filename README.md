# Search Tree Traversal

This is a project to visualise a graph and the different algorithms used to traverse it

## Installation

You can run the program as a standalone executable for Windows and Linux, downloadable from the releases page. The project is also available as a web app, currently available [here](https://mattbann.itch.io/search-tree-traversal).

### Build from source

Alternatively, you can build the project from source. This requires having Godot v4.1.1 with the build templates installed (Editor->Manage Export Templates):

```sh
git clone https://github.com/MattBann/Search-Tree-Traversal.git
cd Search-Tree-Traversal
mkdir builds
# In the commands below, replace 'godot' with the name/path of your Godot binary
# For linux
godot --export-release "Linux/X11" builds/search-tree-traversal.x86_64

# For windows
godot --export-release "Windows Desktop" builds/search-tree-traversal.exe

# For web (html5)
godot --export-release "Web" builds/search-tree-traversal.html
```

## Getting Started

The program opens in editor mode, allowing you to create a graph with nodes and edges

### Creating a graph

To add nodes:
 - Select one of the three 'Place' buttons in the top bar
 - Left-click anywhere on the white panel to place a new node.
 - You can place as many nodes as you like, but it's important that you have a start node (you can only have one) and *atleast* one goal node
 - Every node has a label (the text in its center). When you place it, the label is the same as its unique ID. This can be changed by right-clicking on the node and selecting 'Change label'. The label does not need to be unique
 - The order you create these nodes in is not important, and a nodes type can be changed by right-clicking on it and selecting an option under 'Convert to:'
 - You can also delete a node by right-clicking it and selecting 'Delete node'
 - Selecting 'Move' from the top panel allows you to drag nodes around

To add edges:
 - Select the 'Connect' button in the top bar
 - Click on the node to create an edge from, then click the node to end it at (to cancel, click the first node again)
 - (Optional) With the 'Enable edge weights' option turned on, click the number next to the edge and type in the new weight. Press enter or click away to confirm
 - Note: all edges are directional. To create a non-directional edge, create two edges in opposite directions and apply the same weight
 - You can delete an edge by right-clicking it. If there is an overlapping edge in the other direction, you are given an option to delete either

The panel on the left gives you a range of options to change the appearance and behaviour of the graph. The main options are:
 - Algorithm - you have a choice of 5 algorithms to use when running the search. These are:
   - Breadth First Search
   - Depth First Search
   - Uniform Cost Search (similar to Dijkstra's Algorithm)
   - A* Search
   - Iterative Deepening Depth First Search
 - Show Heuristics - enabling this option shows a new number under each node showing its straight line distance to the goal (if there are none or multiple goals, this is zero). This is useful for A* search
 - Distance Scale - this option applies a scale to all heuristic values, where 100 means using the raw pixel distance, and 1 means using 1% of that distance. This is useful for modelling real-world examples (e.g. cities) or seeing the effect of less accurate heuristics, since all values are rounded down
 - Force Uniform Path Cost - This option causes any custom edge weights to be ignored. Disabling this option restores your custom edge weights

Once you have setup your graph, you can save it by clicking File->Save in the right-hand corner of the top bar, which saves the graph and options in a plain-text json file with the extension '.stt'.
You can then load this file using File->Open.

Note: in the web version, pressing save will download the file as 'search_tree.stt', as such there is no 'Save as' option. 
Opening a file is treated as a file upload (though it is kept local to your machine) with a 30 second timeout

### Running a search algorithm

To start visualising a search algorithm running, click the 'Start Visualisation' button in the middle of the top bar.
The settings panel is replaced by a set of data including the algorithm and the stage it is at, the current node variable, the expansion list (nodes accessible from the current node) and the queue

You can manually progress the algorithm by clicking 'Step' in the top bar, or it can step in regular intervals by toggling 'Auto step' and adjusting the slider next to it.
When the algorithm reaches an end state (either a goal state been reached or the queue is empty) then on the next 'step' the program will return to edit mode.
You can manually return to edit mode by pressing 'Stop'

## Screenshots

![image](https://github.com/MattBann/Search-Tree-Traversal/assets/69541270/197dac67-fe47-4369-b074-9414289ddfd1)
![image](https://github.com/MattBann/Search-Tree-Traversal/assets/69541270/43991cf8-36b3-4854-b188-a1756c97bb94)
