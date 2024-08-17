# Un gestionnaire de fenêtre fonctionnel

The section in English below

## Introduction

Le but de ce projet est de développer une preuve de concept d'un gestionnaire de fenêtres en mosaïque utilisant un arbre pour décrire les fenêtres du bureau. L'objectif principal est de fournir un accès rapide à la fenêtre active en utilisant un zipper d'arbre.

## Prérequis

Il est nécessaire d’avoir l’environnement Dune pour pouvoir utiliser l’application en OCaml. Pour compiler, taper la commande suivante :

```bash
dune build
```

Les tests unitaires doivent passer sans erreur avec la commande :

```bash
dune runtest
```

Et enfin pour lancer le programme :
```bash
dune exec ocamlwm23
```

## Implémentation

Dans la partie principale du programme, nous utilisons une interface graphique représentant un gestionnaire de fenêtres. Elle utilise la bibliothèque graphique OCamlwm23 pour créer une fenêtre blanche ainsi que des fenêtres colorées, avec une taille par défaut de 640 pixels en largeur et 480 pixels en hauteur.

Une monade option est également utilisée pour permettre de gérer des valeurs optionnelles en utilisant des fonctions bind et return. Cette monade est utilisée pour gérer toutes les actions de création de nouvelles fenêtres et la navigation entre celles qui existent.

L’interface graphique permet la création de fenêtres horizontales et verticales, ainsi que la navigation entre les différentes fenêtres. De nombreux autres raccourcis clavier sont utilisés pour déclencher différentes actions :

- Touche h : permet de créer une nouvelle fenêtre horizontale
- Touche v : permet de créer une nouvelle fenêtre verticale
- Touche n : Sélectionne la fenêtre suivante dans l’ordre de parcours de l’arbre
- Touche p : Sélectionne la fenêtre précédente dans l’ordre de parcours de l’arbre
- Touche + : Augmente le ratio de la fenêtre active de 0,05 avec une limite de 0,95
- Touche - : Diminue le ratio de la fenêtre active de 0,05 avec une limite de 0,05
- Touche q : permet de quitter le programme en affichant le nombre total de fenêtres créées
- Touche z : permet de zoomer sur la fenêtre active
- Touche s : permet de changer de bureau

De plus, des fonctions auxiliaires sont utilisées pour déterminer la couleur de la fenêtre active ou inactive, ainsi que pour limiter le ratio entre les dimensions des différentes fenêtres. La fonction est implémentée de manière récursive pour permettre que la navigation se fasse entre les différentes fenêtres jusqu’à ce que l’utilisateur quitte l’interface graphique en appuyant sur la touche q.

## Améliorations

Après avoir implémenté toutes les fonctionnalités permettant le fonctionnement de l’application, nous avons décidé d’ajouter deux améliorations.

1. Zoom sur la fenêtre active : La première amélioration permet d’augmenter la taille de la fenêtre en appuyant sur la touche « z ». Lorsqu’on appuie sur cette touche, la fenêtre qui a le focus va prendre tout le bureau, le programme va uniquement dessiner cette fenêtre. Si la touche « z » est appuyée une seconde fois, le programme affichera toutes les fenêtres que l’on voyait précédemment avant le zoom.

2. Switch entre deux bureaux virtuels : La deuxième fonctionnalité permet de switcher entre deux bureaux virtuels. Lorsqu’on appuie sur la touche « s », le programme change de bureau virtuel et sauvegarde l’arbre précédent dans une variable. Si l’arbre est vide, un nouvel arbre va être créé sinon le programme dessinera le bureau suivant. Deux bureaux virtuels échangent à chaque fois que l’on appuie sur la touche « s ».

# English description :

## Introduction

The goal of this project is to develop a proof of concept for a tiling window manager that uses a tree to describe the windows on the desktop. The main objective is to provide quick access to the active window using a tree zipper.

## Prerequisites

It is necessary to have the Dune environment to use the OCaml application. To compile, run the following command:

```bash
dune build
```
Unit tests should pass without errors with the command:

```bash
dune runtest
```
And finally, to run the program:

```bash
dune exec ocamlwm23
```

## Implementation

In the main part of the program, we use a graphical interface representing a window manager. It uses the OCamlwm23 graphics library to create a white window as well as colored windows, with a default size of 640 pixels in width and 480 pixels in height.

An option monad is also used to handle optional values using bind and return functions. This monad is used to manage all actions for creating new windows and navigating between existing ones.

The graphical interface allows the creation of horizontal and vertical windows, as well as navigation between different windows. Many other keyboard shortcuts are used to trigger different actions:

- Key h: creates a new horizontal window
- Key v: creates a new vertical window
- Key n: Selects the next window in the tree traversal order
- Key p: Selects the previous window in the tree traversal order
- Key +: Increases the ratio of the active window by 0.05 with a limit of 0.95
- Key -: Decreases the ratio of the active window by 0.05 with a limit of 0.05
- Key q: quits the program and displays the total number of windows created
- Key z: zooms in on the active window
- Key s: switches to a different desktop

Additionally, auxiliary functions are used to determine the color of the active or inactive window, as well as to limit the ratio between the dimensions of different windows. The function is implemented recursively to allow navigation between different windows until the user exits the graphical interface by pressing the q key.

## Improvements

After implementing all the features that allow the application to function, we decided to add two improvements.

1. Zoom on the active window: The first improvement allows increasing the size of the window by pressing the "z" key. When this key is pressed, the window with the focus will take up the entire desktop, and the program will only draw this window. If the "z" key is pressed a second time, the program will display all the windows that were previously visible before the zoom.

2. Switch between two virtual desktops: The second feature allows switching between two virtual desktops. When the "s" key is pressed, the program changes to a different virtual desktop and saves the previous tree in a variable. If the tree is empty, a new tree will be created; otherwise, the program will draw the next desktop. Two virtual desktops are exchanged each time the "s" key is pressed.

