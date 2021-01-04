globals
[
  carte

] ; Déclaration de variables globales
patches-own [ ; Variables propres aux patches
  elevation
  used?
]
turtles-own
[
  start-patch ; Variables propres aux turtles
  final-patch ;....
]

to setup

  ca  ; Remettre tout à zero
  file-open "ElevationData.txt" ; carte réelle
  while [not file-at-end?]
    [
      let next-Y file-read ; ouvrir et lire le fichier colonne des coordonnées Y
      let next-X file-read ; ouvrir et lire le fichier colonne des coordonnées Y
      let next-elevation file-read ; creation variable locale next-elevation capable de lire
                                  ; le fichier de données
      ask patch next-X next-Y [set elevation next-elevation];
  ]
  let min-elevation min [elevation] of patches ; determiner la valeur de l'élévation minimale
  let max-elevation max [elevation] of patches ; determiner la valeur de l'élévation maximale
  file-close
  ask patches [
    set pcolor scale-color green elevation min-elevation max-elevation ; faire une degradation de couleur pour refleter l'élévation du terrain
    set used? false ]

  reset-ticks  ; remettre les ticks à zero


  ;;;;;;;;;;;;;;; Carte virtuelle "commenté"
;  ask patches
;  [
;    let elev1 100 - distancexy 30 30
;    let elev2 50 - distancexy 120 100
;    ifelse elev1 > elev2
;    [set elevation elev1]
;    [set elevation elev2]
;    set pcolor scale-color green elevation 0 100
;    set used? false
;  ]


  crt 50
  [
    set size 4 ; assignation de la taille
    setxy 130 130

    if pen-down?
    [pen-down]

    set shape "butterfly" ;..
    set start-patch patch-here ;....
  ]
end

to go
  ask turtles [
    move
    set used? true    ; Permettte aux turtles de modifier la valeur de la patch
                      ; sur laquelle elles se trouvent
    ;show word "Largeur du corridor finale: " corridor-width
  ]

  tick

  let final-corridor-width corridor-width   ;set final-corridor-width

  if ticks >= 1000
  [
    print word "Largeur du corridor finale: " corridor-width ; Afficher la largeur du corridor final dans le centre de commandes
    stop
    export-plot "corridor-width" ; exporter les données du corridor width sur fichier .csv
    (word "Corridor-output-for-q-" q ".csv")
    ; "c:/My Documents/plot.csv"
  ]
  plot corridor-width

end

to-report corridor-width
  let nPatches  count patches with [used? = true]  ; créer variable locale nommée nPatches, compter les cellules ayant été survolées
  let distMoyenne mean [distance start-patch] of turtles
  ; créer variable locale nommée distMoyenne, faire la moyenne de la distance à la cellule de départ,
  ; pour l’ensemble des turtles.
  report nPatches / distMoyenne

end

to move                      ; procedure de deplacement des agents
  ifelse random-float 1 < q
  [uphill elevation]
  [ move-to one-of neighbors]

  if elevation >= [elevation] of max-one-of neighbors [elevation]
  [stop]

end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
668
469
-1
-1
3.0
1
10
1
1
1
0
0
0
1
0
149
0
149
1
1
1
ticks
30.0

BUTTON
12
27
75
60
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
104
27
167
60
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
12
131
184
164
q
q
0
1
0.4
0.02
1
NIL
HORIZONTAL

PLOT
10
270
210
420
corridor-width.
Distance
Mean corridor width
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

SWITCH
41
70
158
103
pen-down?
pen-down?
0
1
-1000

MONITOR
59
205
173
250
NIL
corridor-width
2
1
11

@#$#@#$#@
# Description ODD du modèle de papillons
Ce fichier décrit le modèle de Pe'er et al. (2005). La description est tirée de la section 3.4 de Railsback et Grimm (2012). Le fichier utilise le format de NetLogo.

## But
Le modèle fut créé pour explorer les questions de corridors virtuels. Sous quelles conditions le comportement d'ascension des papillons mène-t'il à l'émergence de corridors virtuels, c'est-à-dire, de corridors étroits empruntés par les papillons lors de leur ascension? Comment la variabilité dans le comportement des papillons affectera l'émergence de corridors virtuels?

## Entités, variables d'état et échelles
Le modèle comporte deux types d'entités: les papillons et les cellules carrées. Les cellules forment une grille de 150 x 150 patches, et chaque cellule (ou patch) n'a qu'une seule variable d'état (ou patch-own): son élévation. Les papillons ne sont caractérisés que par leur localisation, c'est-à-dire la cellule sur laquelles ils se trouvent. Ainsi, les localisation des papillons sont de type discrètes: les coordonnées x et y du centre de la cellule sur laquelle ils se trouvent. La taille des cellules et la durée d'une itération ne sont pas spécifiées car le modèle est générique, mais lorsque le vrai modèle d'élévation est utilisé, chaque cellule correspond à 25 X 25 m<sup>2</sup>. Les simulations roulent pendant 1000 itérations; la durée d'une itération n'est pas spécifiée mais devrait représenter le temps requis pour qu'un papillons avance de 25 à 35 mètres (la distance d'une cellule aux voisines).

## Processus
Il n'y a qu'un seul processus dans le modèle: le mouvement des papillons. À chaque itération, chaque papillon bouge une fois. L'ordre dans lequel les papillons exécutent l'action n'est pas important puisque les interactions ne sont pas prises en compte.

## Concepts de conception
Le _principe de base_ de ce modèle est le concept de corridors virtuels utilisés par plusieurs individus alors qu'il n'y a rien de particulièrement bénéfique dans ceux-ci. Ce concept est rencontré lorsque des corridors _émergent_ de deux parties du modèle: le comportement adaptatif des papillons et le paysage dans lequel ils se  déplacent. Ce _comportement adaptatif_ est modélisé via une simple règle empirique reproduisant le comportement observé chez des vrais papillons: se déplacer en altitude. Ce comportement est basé sur la compréhension (non incluse dans le modèle) que se déplacer en altitude mènera à l'accouplement et, par le fait même, au succès dans la transmission de gènes, objectif ultime de tout organisme. Puisque nous considérons l'ascension comme objectif premier des papillons, la notion d'_apprentissage_ n'est pas utilisée dans le modèle.

La _détection_ est importante dans ce modèle: les papillons sont présumés aptes à identifier quelle cellule parmi son voisinage a la plus haute altitude, mais aucune information au dela du voisinage ne lui est accessible. (Les études terrain de Pe'er 2003 s'attardaient à connaître jusqu'à quelle distance les papillons perçoivent les différences d'élévation.)

Le modèle n'inclut pas d'_interaction_ entre les papillons; dans ses études de terrain, Pe'er (2003) arriva à la conclusion que les papillons réels interagissent (ils cessent parfois leur ascension pour aller à la rencontre d'autres papillons pendant un moment), mais décida que ce comportement n'était pas dans un modèle de corridors virtuels.

La _stochasticité_ est utilisée pour représenter deux sources de variabilité dans les mouvements trop complexes pour être représenté de façon mécaniste. Les vrais papillons ne se déplacent pas toujours directement vers le sommet, notamment à cause de 1) limites dans l'habileté des papillons à détecter le sommet le plus élevé dans leur voisinage, et 2) facteurs autres que la topographier (p.ex. fleurs) influencant la direction et le mouvement. Cette variabilité est représentée en assumant que les papillons ne se déplacent pas vers le sommet à chaque itération; parfois, ils vont dans une direction aléatoire. Si un papillons se déplace vers le sommet ou aléatoire à un temps donné est fonction d'un paramètre _q_, étant la probabilité qu'un individu se déplace au sommet plutôt qu'aléatoirement.

Afin de permettre l'_observation_ de corridors virtuels, nous définiront une mesure spécifique de "largeur de corridor" représentant la largeur de territoire du chemin emprunté par un papillon, de son point de départ au sommet.

## Initialisation
La topographie du paysage (l'élévation de chaque patch) est initialisée lorsque le modèle démarre. Deux types de paysages sont utilisés dans différentes versions du modèle: (1) une topographie artificielle avec deux sommets, et (2) la topographie d'un site d'étude, importée d'un fichier contenant les valeurs d'élévation pour chaque cellule. Les papillons sont initialisés en créant 500 inidvidus et en définissant leur localisation d'origine au même endroit.

## Intrants
L'environnement est constant, alors le modèle n'a aucun intrant

## Sous-modèles
Le sous-modèle de mouvement (ou procédure de mouvement) définit comment les papillons décident de se déplacer 1) en altitude ou 2) aléatoirement. Premièrement, se déplacer en altitude est définit comme se déplacer vers la cellule voisine ayant la plus haute valeur d'élévation; si deux cellules ont la même élévation, une sera sélectionnée aléatoirement. "Se déplacer aléatoirement" est défini comme se déplacer sur une des cellules voisines, avec une probabilité égale pour chacune. Les cellules "voisines" sont les 8 cellules entourant la patch sur laquelle se retrouve un papillon. La décision de se déplacer en altitude ou aléatoirement est contrôlée par le paramètre _q_, qui varie de 0.0 à 1.0 (_q_ est une variable globale: tous les papillons utilisent la même valeur). À chaque itération, chaque papillon "pige" un nombre aléatoire provenant d'une distribution uniforme entre 0.0 et 1.0. Si ce nombre est inférieur à _q_, le papillon ira vers un sommet, sinon, il bougera de façon aléatoire.

## RÉFÉRENCES
Pe’er, G., Saltz, D. & Frank, K. 2005. Virtual corridors for conservation management. _Conservation Biology_, 19, 1997–2003.

Pe’er, G. 2003. Spatial and behavioral determinants of butterfly movement patterns in topographically complex landscapes. Ph.D. thesis, Ben-Gurion University of the Negev.

Railsback, S. & Grimm, V. 2012. _Agent-based and individual-based modeling: A practical introduction_. Princeton University Press, Princeton, NJ.

###_Exercice traduit par Jonathan Gaudreau, 2014. Université de Montréal._
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
