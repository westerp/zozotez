# Library of EBF-macroes as the core building blocks #
Previously I wrote about [the memory design](MemoryDesign.md) of Zozotez. The Design of how to arrange memory in BF is a very important matter since there is not support for objects by default. Every data structure other than fixed place cells has to be emulated. With the power of EBF comes macroes with entry-address which is known by the compiler. Thus ` $a>>>&copy_a ` and the definition ` {copy_a $a(-^0+^1+)^1(-$a+)} ` will work on many places in the source without having to create specific macroes.This is what I have done with my high order macroes.

I have defined stack and program stack functions: &stack\_push , &stack\_pop, &pc\_push, &pc\_pop which retrieves or pushes to the area in which the macro was called. This means I can get stack contents to any fo my ax-fx register.

I have defined symbol macroes. &sym\_open, whichuses the current location as index. &sym\_close (which does not take any argument) and &sym\_get_`<name>` and &sym\_set_`<name>` for each of the parameters string\_ref, assoc\_ref and param\_list.

I have defined similar list macros using lis as prefix. &lis\_open, &lis\_close, &lis\_get_`<name>` and &lis\_set_`<name>`.

All of these are higher order that uses lower order macroes. And these are perfect buildingblocks for implementing primitive lisp operations. (set-car $bx (car $ax)) can be done like this:

```
  $ax &lis_open       ; open array element dictated by $ax
  $ax = &lis_get_car  ; get the car parameter of the opened array element
  &lis_close          ; close array (only one address can be opened at a time)
  $bx &lis_open       ; open target cell whose address is in $bx
  $ax &lis_set_car    ; set the car parameter to the value dictated by $ax
```

On the array side the operations are designed not to clear what is copied, while on the register side everything is destructive. If I wanted to use the car of the scond line twice I need to make local copies before usng the operations. Anyway it looks very simple, but keep in mind that these macroes contains many macroes to do their work. eg. &lis\_get\_car is created by using a set of lower order macroes, many of which are reused in most of the other lis_`*`-macroes:_

```
{lis_get_car
  &lis_to         ; MOVES TO opened list element
  $car(-          ; goto type data
    &lis_backup   ; backup to higher crumble
    &lis_from     ; move back to variable
    ^0+           ; set calling parameter
    &lis_to       ; back to list element
  )               ; self balancing
  &lis_restore    ; copies backup to current position
  &lis_from       ; goes back to variable area
}
```

The `^0` is the key here. It is the address of which the macro was called. For the sake of connsistency, here is the low order macro definition of &lis\_to

```
{lis_to $lis_crumble
  [@end to $lis_crumble] ; loop until first lis_crimble which is clear
}
```