globals[
  max-energy          ;maximum energy (value) same for all turtles
  attention-distance  ;attention distance (value) same for all turtles
  attention-angle     ;attention angle (value) same for all turtles
  need-energy-th      ;energy threshold for a request (value) same for all turtles
  share-energy-th     ;energy threshold to be able to share (value) same for all turtles
  initial-trees       ;initial number of trees (value)
  initial-fruit       ;fruit in each tree (value) same for all trees
]

breed[turts turt]
breed[trees tree]

turts-own[
  energy          ;energy to move (value)
  cooperative?    ;cooperative? (boolean)
  memory?         ;memory? (boolean)
  language?       ;language? (boolean)
  knowledge       ;memorized links with other turtles
]

trees-own[
  fruit    ;number of fruit in each tree (value)
]

to setup
  ca
  ask patches [set pcolor 39]

  ;set globals

  set max-energy 100
  set attention-distance 9
  set attention-angle 120
  set need-energy-th 33
  set share-energy-th 33
  set initial-trees 3
  set initial-fruit 5

  ;put turts and trees

  put-turts C true false false
  let NC 100 - C
  put-turts NC false false false

  if experiment = 2 [ask turts with [cooperative?] [set memory? true]]
  if experiment = 3 [ask turts with [cooperative?] [set memory? true set language? true]]
  if experiment = 4 [ask turts [set memory? true set language? true]]

  put-trees initial-trees

  reset-ticks
end

to put-turts [v1 b1 b2 b3]
  create-turts v1 [
    setxy random-xcor random-ycor
    set energy (random 99) + 1
    set cooperative? b1
    set memory? b2
    set language? b3
    set knowledge turtle-set no-turtles
    ifelse cooperative? [set color blue][set color red]
  ]
end

to put-trees [v1]
  create-trees v1 [
    set shape "tree"
    setxy random-xcor random-ycor
    set color green
    set size 2
    set fruit initial-fruit
    ]
end

to go
  ask turts [explore-and-feed]
  ask turts [if energy < need-energy-th [interact]]
  ask turts [if energy <= 0 [die]]
  tick
  if ticks mod (2 * 2 ^ (3 - rr)) = 0 [put-trees 1]
  if ticks mod 2000 = 0 [stop]
end

to explore-and-feed
  let trees-in-sight trees in-cone attention-distance attention-angle
  ifelse any? trees-in-sight [
    let target-tree min-one-of trees-in-sight [distance myself]
    face target-tree
    forward-step
    if patch-here = [patch-here] of target-tree[
      ask target-tree [set fruit fruit - 1 if fruit = 0 [die]]
      set energy max-energy
      random-step]
    ]
  [
  random-step
  ]
end

to forward-step
  fd 1
  set energy energy - 1
end

to random-step
  lt random-float attention-angle / 2 rt random-float attention-angle / 2
  fd 1
  set energy energy - 1
end

to interact

  ;choose target

  let candidates turts in-cone attention-distance attention-angle with [energy > [energy] of myself and energy > share-energy-th]
  if any? candidates [
    let target one-of candidates

    ;interaction

    ;If target is not cooperative the interaction turns bad in selfs perpective.
    ;If target is cooperative, cooperation is conditional based on memory (of target), or inconditional if target does not have memory or memory is full.
    ;Note that only bad turts are memorized. If target remembers turt it s because it s bad
    ;(knowledge from previous interaction between the two or from sharing info with other turts).
    ;If target remembers turt, energy is not shared by target. The interaction turns bad in selfs perpective.
    ;Not remembering is equivalent to not having memory or memory full => inconditional cooperation. Energy is shared by target.
    ;If energy is shared they can also share knowledge. If both have language they also share info about their links with other turtles.
    ;After interacting, if interaction was bad in selfs perpective, self has memory and memory is not full, the bad turt is memorized.

    let self-had-a-negative-interaction false

    ifelse [cooperative?] of target [
      ifelse [not remembers? myself] of target[
        share-energy self target
        if language? and [language?] of target [share-info self target]
      ][
        set self-had-a-negative-interaction true
      ]
    ][
      set self-had-a-negative-interaction true
    ]

    if self-had-a-negative-interaction [
      if memory? and not memory-full? [memorize target]
    ]
  ]
  ;note that in repeated interactions with the same partner links and records of links in memory are not duplicated, but their are enventuallt subject to changes
end

to-report memory-full?
  ifelse count knowledge = memory-limit [report true][report false]
end

to memorize [t]
  if not remembers? t [set knowledge (turtle-set knowledge t)]
end

to-report remembers? [t]
  ifelse member? t knowledge [report true][report false]
end

to share-energy [t1 t2]
  let both (turtle-set t1 t2)
  let half-of-combined-energies ((sum [energy] of both) / 2)
  ask both [set energy half-of-combined-energies]
end

to share-info [t1 t2]
  first-gets-from-second t1 t2
  first-gets-from-second t2 t1
end

to first-gets-from-second [t1 t2]
  let new-bad-turts other ([knowledge] of t2)
  ask new-bad-turts [ if [not memory-full?] of t1 [ask t1 [memorize myself]]]
  ;memorized turts are not duplicated in memory
end
@#$#@#$#@
GRAPHICS-WINDOW
496
10
912
427
-1
-1
8.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
0
0
1
ticks
30.0

BUTTON
33
21
106
54
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

SLIDER
338
19
479
52
C
C
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
21
171
193
204
rr
rr
1
3
2.0
1
1
NIL
HORIZONTAL

BUTTON
116
21
179
54
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

PLOT
8
220
370
449
Pop
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"C" 1.0 0 -13345367 true "" "plot count turts with [cooperative?]"
"NC" 1.0 0 -2674135 true "" "plot count turts with [not cooperative?]"
"T" 1.0 0 -10899396 true "" "plot count trees"

MONITOR
401
230
458
275
C
count turts with [cooperative?]
3
1
11

MONITOR
401
289
458
334
NC
count turts with [not cooperative?]
17
1
11

SLIDER
308
67
480
100
memory-limit
memory-limit
0
100
100.0
1
1
NIL
HORIZONTAL

CHOOSER
226
10
318
55
experiment
experiment
1 2 3 4
0

TEXTBOX
22
84
443
181
1 = no memory or language\n2 = cooperative (C) have memory\n3 = cooperative have memory and language\n4 = non-cooperative (NC) also have memory and language
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model investigates the success of cooperation when under ecological pressure, including when non-cooperative agents are also present in the system and take advantage of cooperative efforts for the survival of the group. In particular, two cognitive abilities are tested in such circumstances: memory and language, which are necessary to build and maintain a network of direct and indirect reciprocity, thus allowing for stable cooperation and better survival chances.

## HOW IT WORKS

100 agents are placed randomly in space with random initial energy between 1 and 100 (maximum possible energy). A population size of 50 to 100 individuals is considered based on estimates for the group size of hunters–gatherers societies. 

Trees are randomly put in space, each with 5 fruits. Trees die when all fruit is collected. Ecological pressure is determined solely by the nature’s regrowth rate **rr**, that is, a new tree comes to existence whenever (ticks mod 2 x (2^3 - rr )) = 0. 

Agents move randomly: one step per tick inside their perception field, defined by a 120º attentional angle and a 9 step attentional distance. Agents loose 1 unit of energy per step and when they loose all their energy they die. If a tree is detected in the agent’s perception field he moves towards the tree to collect one fruit. If more than one tree is detected he moves towards the closest tree. If other agents with energy greater than 33 are detected in his perception field and ego has energy less than 33, he sends an energy request to one of these agents. If the request is accepted, their energy is summed and divided by both. If the request is refused he may be able to memorize the other’s identity. If an energy transfer is successful, agents may also share information in memory, independently of who made the request. In that case, their memory after the interaction is the concatenation of their personal records (before the interaction) of the identities of the non-cooperative agents. 

Agents can be cooperative (C) or selfish/non cooperative (NC). Cooperative agents are always available to share their energy (if greater than 33 units), unless they know their partner from previous interactions or "rumors" (conditional cooperation based on memory or memory and language). Selfish agents are never available to share their energy.


## HOW TO USE IT

Control the regrowth rate my manipulating **rr**. High, medium and low ecological pressure are defined by **rr** = 1, 2 and 3 respectively. 

The initial number of cooperative agents in the system is controlled by **C**, the rest (100 - C) are not cooperative. 

The number of agents an agent is able to memorize is controlled by **memory-limit**. (only relevant in experiments 2 to 4; See below)

Select experiment:

1. no memory or language
2. cooperative (C) have memory
3. cooperative have memory and language
4. non-cooperative (NC) also have memory and language

setup and go.

## THINGS TO NOTICE

How do you compare the impact of different **rr** values on global survival chances? 

How is the success of cooperation changed by the initial number of cooperative agents in the system?

How to interpret the effect of memory and language on the success of cooperation?

## THINGS TO TRY

Try comparing the success of cooperation across experiments for different values of **C** and **vr**.

## EXTENDING THE MODEL

This model was developed specifically to test the importance of reciprocity and underlying cognitive mechanisms for stable cooperation under ecological adversity. As such, all parameters were set empirically such that, on one hand, survival chances are affected by ecological pressure, and on the other, promoted by an interaction frequency that is enough to allow many reciprocity opportunities. For that reason parameters where set implicitly in the code. But it could be interestign to manipulate all parameters parameters explicitly and try for example different proportions of energy sharing.

Ideas:

* Create obstacles and let the agents follow the walls by avoiding them.
* Allow the agents to reconsider their strategy based on their previous experience. Things like gratitute and other complex social emotions and moral rules may be interesting to investigate in this type of setting.
* Allow agents to reproduce.

## RELATED MODELS

In NetLogo Modeling Commons:

Cooperation
Altruism
Reciprocal Altruism in Vampire Bats

## CREDITS AND REFERENCES

This model was originaly inspired by:

Zibetti, E., Carrignon, S., & Bredeche, N. (2016). ACACIA-ES: an agent-based modeling and simulation tool for investigating social behaviors in resource-limited two-dimensional environments. Mind & Society, 15(1), 83-104.


## HOW TO CITE

## COPYRIGHT AND LICENSE

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">Cooperation Under Ecological Pressure: Cognitive Adaptations.</span> by <span xmlns:cc="http://creativecommons.org/ns#" property="cc:attributionName">David N. Sousa</span> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
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
NetLogo 6.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="E2" repetitions="500" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turts with [cooperative?]</metric>
    <metric>count turts with [not cooperative?]</metric>
    <metric>count trees</metric>
    <enumeratedValueSet variable="rr">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-limit">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E3" repetitions="500" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turts with [cooperative?]</metric>
    <metric>count turts with [not cooperative?]</metric>
    <metric>count trees</metric>
    <enumeratedValueSet variable="rr">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-limit">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E4" repetitions="500" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turts with [cooperative?]</metric>
    <metric>count turts with [not cooperative?]</metric>
    <metric>count trees</metric>
    <enumeratedValueSet variable="rr">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-limit">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E5" repetitions="500" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turts with [cooperative?]</metric>
    <metric>count turts with [not cooperative?]</metric>
    <metric>count trees</metric>
    <enumeratedValueSet variable="rr">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-limit">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment">
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E6RR2" repetitions="500" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turts with [cooperative?]</metric>
    <metric>count turts</metric>
    <enumeratedValueSet variable="rr">
      <value value="2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="memory-limit">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E1" repetitions="500" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turts</metric>
    <enumeratedValueSet variable="rr">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="C">
      <value value="100"/>
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="memory-limit">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E6RR1" repetitions="500" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turts with [cooperative?]</metric>
    <metric>count turts</metric>
    <enumeratedValueSet variable="rr">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="memory-limit">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="E6RR3" repetitions="500" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turts with [cooperative?]</metric>
    <metric>count turts</metric>
    <enumeratedValueSet variable="rr">
      <value value="3"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="memory-limit">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="experiment">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
