breed [ sellers seller ]                  ; One of the two type of agents, sellers (businesses)
breed [ buyers buyer ]                    ; One of the two type of agents, buyers (consumers)

globals [
  population                              ; The amount of agents in the model. There is an equal amount of both agents
  min-price                               ; The minimum price
  economic-conditions                     ; The economic conditions. There are three conditions: strong, weak and balanced
  exchange-rate                           ; The current exchange rate. There are three categories: strong, weak and balanced

]

turtles-own [
  money                                   ; The amount of money each turtle has at the beinning of the simulation
  percent
  successful-trade-behaviour              ; The behaviour of the agent following a successful trade
  unsuccessful-trade-behaviour            ; The behaviour of the agent following a unsuccessful trade
  ]

sellers-own [
  whiskey-stock-quantity                  ; The amount of whisky stock in the business
  whiskey-price                           ; The asking price of one unit of whisky
  whiskey-sold                            ; The quantity of whisky that has been sold
  revenue                                 ; The revenue of the business
  profit                                  ; The profit of the business
  cereal-cost                             ; The cost of cereals used in the production process for the business
  storage-cost                            ; The storage cost of whisky to the business
  total-cereal-costs                      ; The total costs of cereals for the business
  total-storage-costs                     ; The total costs of storage fpr the business

  ]

buyers-own [
  want-to-buy                             ; The quantity the buyer wants to buy
  willing-to-pay                          ; The price the buyer is willing to pay for one unit of whisky
  whiskey-purchased                       ; The quantity that the buyer has bought
]


to setup
  clear-all

  ask patches [
    set pcolor cyan ]

  ; Set the global variables
  set min-price 0.5
  set population n-population


    ; Set the variables of the sellers
    create-sellers population [
    set shape "house"
    setxy random-xcor random-ycor
    set size 1.75
    set color yellow
    set money 0
    set revenue money
    set whiskey-stock-quantity 40000
    set whiskey-price whiskey-price


    ;Set cost of cereals, depending on quantity of cereals imported
    if cereals-imported-quantity = "Fully Imported" [
      set cereal-cost (0.05 * exchange-rate) ] ; Fully imported means cheapest cereals
    if cereals-imported-quantity = "Half Imported" [
      set cereal-cost (0.12 * exchange-rate) ]; Half imported means fairly priced cereals
     if cereals-imported-quantity = "None Imported" [
      set cereal-cost 0.18  ] ; None imported (using home grown cereals) meaning highly priced cereals

    ; Set asking price of whiskey and storage cost, depending on the age of the whiskey
    ; Intial value has been provided for each whiskey price to avoid an extreme low value being returned the random function
   if whiskey-prices = "Aged 10 Years - Moderately priced" [
      set whiskey-price 30 + random 50
      set storage-cost 0.02 ]
    if whiskey-prices = "Aged 20 Years - Highly priced" [
      set whiskey-price 100 + random 100
      set storage-cost 0.03]
    if whiskey-prices = "Aged 30 Years - Expensive" [
      set whiskey-price 500 + random 1000
      set storage-cost 0.04 ]
    if whiskey-prices = "Aged 40 Years (rare bottles) - Very expensive" [
      set whiskey-price 1000 + random 2500
      set storage-cost 0.05  ]
    if whiskey-prices = "Mix of all whiskey prices" [
      set whiskey-price 30 + random 4000
      set storage-cost 0.02 + random 0.03 ]


    ; Set after trade behaviour of sellers
    ask sellers[
    if seller-trading-behaviour = "normal" [
      set successful-trade-behaviour [-> change-price 1.25 ]
      set unsuccessful-trade-behaviour    [-> change-price -1.25 ] ]
    ]
    ask sellers [
    if seller-trading-behaviour = "desperate" [
      set successful-trade-behaviour [-> change-price 4.5 ]
      set unsuccessful-trade-behaviour    [-> change-price -4.5 ] ]
    ]

  ; Set the state of the economy, which will influence the asking price of the seller
  if state-of-economy = "Strong" [
    set economic-conditions  1.2 ]
  if state-of-economy = "Weak" [
    set economic-conditions 0.8 ]
  if state-of-economy = "Balanced" [
    set economic-conditions 1 ]

    ; Set the exchange rate, which will influece the buying power when trading internationally
  if domestic-currency-state = "Strong" [
    set exchange-rate 1.25 ]
  if domestic-currency-state = "Weak" [
    set exchange-rate 0.75 ]
  if domestic-currency-state = "Balanced" [
    set exchange-rate 1 ]

     set whiskey-price (whiskey-price * economic-conditions)
  ]

    ;  Set the variables of the buyers
    create-buyers population [
    set shape "person"
    set size 1.5
    set color magenta
    setxy random-xcor random-ycor
    set want-to-buy 550
    set money 9999999


   ; Asking price of whiskey and storage cost, depending on the age of the whiskey
   ; Intial value has been provided for each whiskey price to avoid an extreme low value being returned the random function
   if whiskey-prices = "Aged 10 Years - Moderately priced" [
      set willing-to-pay 30 + random 50  ]
    if whiskey-prices = "Aged 20 Years - Highly priced" [
      set willing-to-pay 100 + random 100   ]
    if whiskey-prices = "Aged 30 Years - Expensive" [
      set willing-to-pay 500 + random 750 ]
    if whiskey-prices = "Aged 40 Years (rare bottles) - Very expensive" [
      set willing-to-pay 1000 + random 2500 ]
    if whiskey-prices = "Mix of all whiskey prices" [
      set willing-to-pay 30 + random 4000 ]



    ;  Set after trade behaviour of buyers
     if buyer-trading-behaviour = "normal"[
      set successful-trade-behaviour [-> change-payment -1.25 ]
      set unsuccessful-trade-behaviour    [-> change-payment  1.25 ]
    ]
      if buyer-trading-behaviour = "desperate"[
        set successful-trade-behaviour [-> change-payment -4.5 ]
        set unsuccessful-trade-behaviour    [-> change-payment  4.5 ]
      ]


  ; Set the state of the economy, which will influence amount the buyer is willing to spend
  if state-of-economy = "Strong" [
    set economic-conditions  1.2 ]
  if state-of-economy = "Weak" [
    set economic-conditions 0.8 ]
  if state-of-economy = "Balanced" [
    set economic-conditions 1 ]

  set willing-to-pay (willing-to-pay * economic-conditions) ]



  reset-ticks
end



to go
  if (mean [want-to-buy] of buyers <= 10) [stop]
  ;if (mean [want-to-buy] of buyers <= 50) [stop]
  clear-drawing

  let offset 1 + ticks mod population
  foreach (range 0 population) [ i ->
    let the-seller seller (population * 0 + i)
    let the-buyer buyer (population * 1 + ((i + offset) mod population))
    ask the-buyer [ trade the-seller ] ;trade with that particular seller
    ]

  tick
end


to change-price [ change ]
  let before whiskey-price
  set percent 1 + (change / 100)
  set whiskey-price check-for-min-price (precision (percent * whiskey-price) 2)
  if before = whiskey-price [
    if change < 0 and before != min-price [
      set whiskey-price precision (whiskey-price - min-price) 2
    ]
    if change > 0 [
      set whiskey-price precision (whiskey-price + min-price) 2
    ]
  ]
end

to change-payment [ change ]
  let before willing-to-pay
  set percent 1 + (change / 100)
  set willing-to-pay check-for-min-price (precision (percent * willing-to-pay) 2)
  if before = willing-to-pay [
    if change < 0 and before != min-price [
      set willing-to-pay precision (willing-to-pay - min-price) 2
    ]
    if change > 0 [
      set willing-to-pay precision (willing-to-pay + min-price) 2
    ]
  ]
  if willing-to-pay > money [ set willing-to-pay money ]
end



to trade [ the-seller ]
  let seller-price [whiskey-price] of the-seller

  ifelse ([whiskey-stock-quantity] of the-seller > 0 and want-to-buy > 0 and  [whiskey-price] of the-seller <= willing-to-pay) [

    move-to the-seller

    set money (money - seller-price)
    set want-to-buy (want-to-buy - 1)
    set whiskey-purchased (whiskey-purchased + 1)


    ask the-seller [
    ;set items-for-sale (items-for-sale - 1)
    set whiskey-stock-quantity (whiskey-stock-quantity - 1)

    set money (money + seller-price)
    set revenue (revenue + whiskey-price)
    set profit (profit + ( whiskey-price - ( whiskey-price * ( cereal-cost + storage-cost ) ) ) )
    set whiskey-sold (whiskey-sold + 1)
    set total-cereal-costs (cereal-cost * whiskey-sold)
    set total-storage-costs (storage-cost * whiskey-sold)
    run successful-trade-behaviour
    ]

    run successful-trade-behaviour


  ] [
    ; If no trade was made, the following code is carried out
    move-to patch 0 random-ycor ; Buyers move back to the middle of the grid and wait their turn to make their next trade
    ask the-seller [ run unsuccessful-trade-behaviour  ]
    run unsuccessful-trade-behaviour
  ]
end


to-report check-for-min-price [ value ]
  report precision ifelse-value value < min-price [min-price] [value] 2
end


@#$#@#$#@
GRAPHICS-WINDOW
234
10
695
472
-1
-1
13.73
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
87
71
142
106
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

BUTTON
118
36
181
69
NIL
go
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
52
35
111
68
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
29
318
200
363
seller-trading-behaviour
seller-trading-behaviour
"normal" "desperate"
1

CHOOSER
29
363
200
408
buyer-trading-behaviour
buyer-trading-behaviour
"normal" "desperate"
1

CHOOSER
28
204
200
249
cereals-imported-quantity
cereals-imported-quantity
"None Imported" "Half Imported" "Fully Imported"
2

CHOOSER
28
262
201
307
whiskey-prices
whiskey-prices
"Aged 10 Years - Moderately priced" "Aged 20 Years - Highly priced" "Aged 30 Years - Expensive" "Aged 40 Years - Very expensive" "Mix of all whiskey prices"
4

SLIDER
28
161
200
194
n-population
n-population
0
150
75.0
1
1
NIL
HORIZONTAL

PLOT
740
10
1091
160
Profit
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
"Profit" 1.0 0 -5509967 true "" "plot mean [profit] of sellers"
"Revenue" 1.0 0 -1184463 true "" "plot mean [revenue] of sellers"

PLOT
740
160
1092
310
Whisky Prices
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Whiskey Prices" 1.0 0 -955883 true "" "plot mean [whiskey-price] of sellers"

PLOT
740
309
1093
459
Price Buyer is Willing to Pay
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot  mean [willing-to-pay] of buyers"

PLOT
1093
307
1446
459
Whisky Sales
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13840069 true "" "plot mean [whiskey-sold] of sellers"

PLOT
1090
10
1446
160
Total Cereal Costs
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Ceral Costs" 1.0 0 -11221820 true "" "plot mean [total-cereal-costs] of sellers"

PLOT
1092
160
1446
310
Total Storage Costs
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Total Storage Costs" 1.0 0 -11221820 true "" "plot mean [total-storage-costs] of sellers"

CHOOSER
29
414
201
459
state-of-economy
state-of-economy
"Strong" "Weak" "Balanced"
1

CHOOSER
29
458
201
503
domestic-currency-state
domestic-currency-state
"Strong" "Weak" "Balanced"
1

@#$#@#$#@
## Purpose

The purpose of this model is to explore the possibility of requiring Scotch whisky to be made by only Scottish grown wheats, or alternatively following a comparative advantage model and increasing the import volume of wheats, to be used in the production of Scotch whiskey. The purpose of the agents within the model is to trade at the best possible price. The model will investigate how these different scenarios impact whisky prices and profit of businesses who selling Scotch whisky. Furthermore, the model will assess how different states of the economy and how the strength of exchange rates can influence business revenue and profit. 

## Entities, state variables and scales

Entitles and State Variables 
The entities within this model are consumers and businesses, both represented by turtles. Each agent has a state variable money, which for the consumers, holds the amount of money they must spend, and for the business, holds the amount of money they have gained from consumers. In addition, both agents have a state variable for their behaviour after a successful or unsuccessful trade. These two state variables are successful trade behaviour and unsuccessful trade behaviour. The purpose of these state variables is to allow for an adjustment in the asking or selling price of the agents. 

Scale
For every tick, it represents one trading day, where one trade per agent is made each day. 

Landscape
The landscape is a grid of 33x33 patches, coloured cyan. Each consumer is represented by a person figure, coloured purple. The businesses in the grid are represented by yellow houses. In the first tick, both consumers and businesses are placed randomly on the grid. After being placed, businesses will stay situated in that patch for the whole simulation. Consumers will move to the patch of a business to make a trade, if successful in trading they will move to another business and if unsuccessful, they will relocate themselves in the middle of the landscape until they make their next move to a business. Consumers are placed in the middle so those who were unsuccessful are easily identifiable. 


## Process overview and scheduling 

In each round (tick), the agents do the following:
The consumers will move to a business with the intention of purchasing one unit of whisky. Each consumer will have their ideal price they are willing to pay, and each business will have their ideal asking price for one unit of whisky. So, when a consumer arrives at a business they will assess if the price they are willing to pay is more than the asking price, if this is the case, they will make a purchase; however, if their price they are willing to pay is less than the asking price, they will move to the middle of the grid. 
If the consumer was successful in making a purchase, they will decrease the amount they are willing to spend and if they were unsuccessful, they will increase their willing to spend amount. Similarly, businesses carry these actions too. If they are unsuccessful in making a sale, they lower their asking price and if they are successful, they will increase their asking price.

Willing to Pay. At the beginning of the simulation, buyers will be assigned a price they are willing to pay. This price will change depending on the success of their trades.

Whiskey Price. At the beginning of the simulation, sellers will be assigned an asking price for one unit of whisky. This price will change depending on the success of their trades.

## Design concepts 

Basic principles 
The basic top of this model is to investigate how different volume of imported cereals for Scotch whisky production can influence business profit, whisky prices and volume sold. Consumers within the model wishes to purchase 400 unit of whisky, they do this by finding a business who is selling whisky at a price they deem suitable for them. 

Emergence 
The model’s primary goal is to monitor how business profit and whisky prices are influenced by the volume of imported cereals used in the production of whisky. 

Adaptive Behaviour
Adaptive behaviour is present within this model for both the consumers and businesses. Consumers decide to purchase one unit of whisky from a particular business or to decline the trade and move on to the next business. The decision to make a purchase or not, is decided by how much the consumer is willing to spend and this amount, is influenced by their previous encounter with a business. If in the previous encounter, the consumer was successful in purchasing one unit of whisky, they will lower the price they are willing to spend for the next business they arrive at. Conversely, if they were unsuccessful in making a purchase, they will increase the amount they are willing to spend. 
This behaviour is similar for businesses. If they are successful in making a sale, they will increase their whisky price, and if they are not successful, they will lower their whisky price. 

Objectives
The objective of each consumer is to purchase 550 units of whisky, while spending the least amount of money possible. On the other hand, businesses will aim maximise their whisky sales and generate high levels of revenue and profit.  

Prediction 
An agent’s price will be predicted depending on if they were successful or unsuccessful in making a trade. 

Interactions
The interaction within this model takes place when a consumer arrives at a business and observes the asking price for one unit of whisky. From this, they will decide whether to make a trade or not. If the trade is unsuccessful, the consumer will move to the middle of the grid and then interact with another business. 

Stochasticity 
Stochasticity is present for both consumers and businesses. Randomness exists in how much the consumer is willing to spend and, in the business asking price. To avoid extremely low values, an initial value is given then a random number is added. Stochasticity is used in this model to replicate how businesses can have varying prices for similar products, and how consumers can have different amounts they wish to spend. 

Observations
The view shows businesses, which are represented by yellow houses and consumers, which are represented by purple people. In addition, results can be observed from the plots within the model. These plots show the whisky prices and the profit and revenue the businesses have made. All plots update at every tick.  


## Initialisation 
The model begins by creating an equal number of consumers and businesses, which is determined by the user. Each business is given a random selling price and each consumer is assigned a random price they are willing to pay, this is influenced by the type of whisky being sold – the type of whisky on sale is decided by the user. In addition, the user determines the volume of imported cereals being used by the businesses in their production process; this volume impacts the overall profit of the business due to there being different cereal costs, depending on the volume of cereals imported. Furthermore, the behaviour of both the consumers and businesses can be set by the user; the two options are normal or desperate. 
Once the simulation begins, consumers will move to businesses and evaluate the asking price. The price the consumer is willing to pay is further influenced by their encounter with a business, if they are successful in purchasing whisky they will decrease their price, in hope of securing a cheaper trade in their next encounter. The opposite is true if they are unsuccessful. The business asking price is also further influenced by their interaction with a consumer, if successful in securing a trade, they will raise their price, if unsuccessful they will decrease their price.  

Input Data
The model does not facilitate any input of external data.


## Sub models

There are multiple parameters within this model. Firstly, the population of agents is decided by the n-population slider - this results in an equal amount of both types of agents. This value is initially set to 75 but ranges from 1 to 150. 
Secondly, the volume of imported cereals is determined by the cereals-imported-quantity button. There are three values, ‘none imported’, ‘half imported’, and ‘fully imported’. These values influence the profit of the business as the imported volumes have different prices. 
Thirdly, whisky prices within the model can be determined by whisky-prices button. There are five whisky prices available: ‘Aged 10 Years – Moderately Priced’, ‘Aged 20 Years – Highly priced’, ‘Aged 30 Years – Expensive’, ’40 Years – Very expensive’, and ‘Mix of all prices’. An initial value is provided for each price and then a random value is added, the more expensive bottles of whisky have a higher initial value and random value. An initial value has been provided to avoid an extremely low price. The price set by the user will influence the revenue and profit of each business.
Lastly, the trading behaviour of both consumers and business can be set by the trading behaviour button. The two values for their behaviour are ‘normal ‘and ‘desperate’, The agent’s behaviour will influence how much of an adjustment in their asking price/willing to pay price after an interaction. 

Willing To Pay. The price the consumer is willing to pay is directly influenced by which whisky price category has been set by the user when initialising the model. 
Whisky Price. The business asking price for one unit of whiskey, which is influenced by the whisky price category that has been set by the user when int initialising the model.
Revenue. Businesses within the model calculate their revenue by adding together the whisky prices of the number of units of whisky sold.
Profit. Profit of the businesses is calculated by subtracting cereal costs and storage costs from revenue. 



## References

Baker, J. and Wilensky, U. (2017). NetLogo Bidding Market model. http://ccl.northwestern.edu/netlogo/models/BiddingMarket. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.


Hamill, Lynne, and G Nigel Gilbert. Agent-Based Modelling in Economics. Wiley, 12 Jan. 2016.
Scotland.org. “Whisky | Scotland.org.” Scotland, www.scotland.org/about-scotland/food-and-drink/whisky#:~:text=It.

Scottish Whiskey Association. “Scotch Whisky Cereals Technical Note: 4th Edition.” Scotch Whisky Association, 30 Aug. 2019, www.scotch-whisky.org.uk/insights/sustainability/cereals/scotch-whisky-cereals-technical-note-4th-edition/#:~:text=By%20law%2C%20Scotch%20Whisky%20must. Accessed 7 Apr. 2022.

The Scotch Advocate. “The History about Scotch-Everything You Need to Know.” EVERYTHING to KNOW about SCOTCH WHISKY, 2018, www.thescotchadvocate.com/history.html.

The Scotch Whisky Association. Scotch Whisky Cereals Technical Note. Aug. 2020.

WhiskeyShop. “The Whisky Shop | Free Delivery on Everything over £99.” Www.whiskyshop.com, www.whiskyshop.com/. Accessed 2 Apr. 2022.

Wilensky, Uri, and William Rand. An Introduction to Agent-Based Modelling : Modelling Natural, Social, and Engineered Complex Systems with NetLogo. Cambridge, Massachusetts, The Mit Press, 17 Apr. 2015.

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
NetLogo 6.2.2
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
