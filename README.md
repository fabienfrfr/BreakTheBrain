# BreakTheBrain

###### Attribution required : Fabien Furfaro (CC 4.0 BY NC ND SA)

![ProofOfConcept](/scale_model.png)

### Game Engine :

Godot Engine - Free and open source 2D and 3D game engine https://godotengine.org.

Some design inspired by GDQuest !

### Ideas of game :

Understand the universal approximation theorem by a puzzle game, for that, move the neurons, change their bias-weight so that the output (in red) corresponds to the desired function (in yellow). Available in itch.io : https://fabienfrfr.itch.io/break-the-brain

"""
Break the codes of an artificial neural network! "Break The Brain" is a puzzle game simulating the functioning of a neural network. The objective is to find the right parameters and the right connections to obtain the desired signal! This game makes it possible to understand the operation of certain properties of neural networks (learn : logic gate, linear combination, classification, gradient, loss function, graph) and a very important theorem: the universal approximation theorem, theorem which explains why neural network work so well in theory! But by playing it, you will understand why it is so difficult to set up in practice! This educational game is a prototype of a project that can be bigger: Battle royale game for use citizen science research to better understand and develop the intuition of artificial neural networks. I'm not a professionnal game developer, if you have any suggestions or advice, don't hesitate! You can also contact me on Instagram blog @fabienfrfr (in French also if you want). The game code is available on my GitHub (Attribution required: Fabien Furfaro (CC 4.0 BY NC ND SA)).
"""

## Algorithme Graph2ComputationNet :
### Input :
* X values

* Weight-Bias Matrix

### Initialization :
Output list = { S1 = X, S1 = 1, ..., Sn = 1}

Order vector = [1,...,1]

Connection matrix = ( a_ij = {1 if != 0; 0 else} )

Calculus vector = [ -1, ..., -1]

### Loop :
Calculus_vector = Connection_matrix * Order_vector

next_index = find(New_Calculus_vector == 1) # first 

Order_vector[next_index] = 0

Output_list[next_index] = linear_combinaison(Output_list, Weight_biais_matrix, next_index)
