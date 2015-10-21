# Carrot, Rabbit, Wolf World in Elixir

## Background

I listened to a couple different podcasts where Francesco Cesarini [talked about a college programing class covering Erlang](https://books.google.com/books?id=Qr_WuvfTSpEC&pg=PR15&lpg=PR15&dq=Francesco+Cesarini+carrots+rabbits+wolves&source=bl&ots=aMWHdDxOHf&sig=TFCp3pkr7hJE1jCDQfjvlsTRMpA&hl=en&sa=X&ved=0CB4Q6AEwAGoVChMIlrimtJ_SyAIVwvceCh05Uwxb#v=onepage&q=Francesco%20Cesarini%20carrots%20rabbits%20wolves&f=false) where the students were assigned a project to model a world where

1. Carrots grow on the board
2. Rabbits travel around the board, eating carrots, and reproducing
3. Wolves travel around eating rabbits and reproducing

There may be more to the project, but that's where I've stopped.

## How to run

1. Clone the repo
2. `iex -S mix`
3. `CarrotWorldServer.sip`

And the world starts printing to the terminal.

### Changing the world settings

carrot_patch.ex, rabbit.ex, wolf.ex all have settings you can change like

```
rabbit.ex

@carrots_in_belly_before_reproduce 1
@day_can_live_without_carrots 10

wolf.ex

@rabbits_in_belly_before_reproduce 5
@day_can_live_without_rabbits 50

carrot_patch.ex

@carrot_growth_points_required 100
````

#### Change the board size

In `iex -S mix` run
`CarrotWorldServer.start(%{board_size: 30})`

And you can set the board size
