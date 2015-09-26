# Chick :: Networking

_This document describes how the networking part of the game works behind the scenes._

## Protocol

### Overview

The protocol used to communicate between client and server sits on top of TCP. Most of the stuff that goes through the socket is a 1:1 translation of the actions done by a client (human player) which makes the protocol rather simple.

### Commands

All commands begin with a 3 character verb, followed by a non-negative number of parameters.

#### Server-side

#### `NEW`

```
NEW <room>
```

Create a new room (and join it).

- `room` is the name of the new room.

#### `ETR`

```
ETR <room>
```

Join/enter a room.

- `room` is the name of the room.

#### `NIC`

```
NIC <nickname>
```

Set own nickname.

- `nickname` is the new nickname.

#### `COL`

```
COL <color>
```

Set own color.

- `color` is the new color.

#### `MOV`

```
MOV <from> <to>
```

Make a move.

- `from` is the source node.
- `to` is the target node.

#### `RDY`

```
RDY
```

Tell the server that you're ready.

#### `PLY`

```
PLY
```

Finalize your moves.

#### `NFO`

```
NFO
```

Get some information. If you're in a room, it requires a list of all connected players. Otherwise it requires a list of all available rooms.

#### `BYE`

```
BYE
```

Leave.

#### Client-side

#### `SUC`

```
SUC
```

Indicate that the previous command was successful.

#### `ERR`

```
ERR <reason>
```

Indicate that the previous command failed.

- `reason` is a short message that describes what went wrong.

#### `MOV`

```
MOV <from> <to>
```

Receive a move.

- `from` is the source node.
- `to` is the target node.

#### `WIN`

```
WIN <player>
```

Indicate that some player won the game.

- `player` is the player who won the game.
