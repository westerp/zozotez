# The basics #

## Symbol ##
A symbol is a string that does not contain the chars `'().` or whitespace.

## The expression ##
An expression is either a symbol or a list of zero or more expressions. A list is enclosed in parenthesis and elements are separated by whitespace. eg.
T
(a b)
(d (a b))

The first element of a list expression is in the operation position while the rest is in argument position. If you are familiar with other programming languages or algebra a function is often written like this: function(arg1, arg2, .. argn) in LISP (and Zozotez) thsi will be written (function arg1 arg2 .. argn).

In LISP functions are often called forms. Things that are considered structures in other languages, like conditionals (if), are called Special forms in LISPs.

# Functions and structures / Forms and Special forms #
## quote ##
One of LISPs special feature is that code and data is made of the same stuff. To pass data without evaluating it as a form one must quote it. In LISP the usual way to do this is to prefix with single quote like this: 'quoted
In LISPS this is a synonym for (quote quoted) and in Zozotez (" quoted). When evaluating the operation position Zozotez sees it is the special form quote and just return the first argument as the evaluation. Other examples:
'(a b c) == (" (a b c)) => (a b c)

## atom (function) ##
As the first function I'd liek to point out that all functions evaluates all the the elements of the form before executing. If one want's the values not evaluated one need to quote them as mentioned before.

An atom is a symbol or the empty list. In Zozotes the symbol s (for symbol) is the equivalent. (s 'x) retuns T while (s '(x)) returns NIL. Notice that T is the equivalent to the boolean true and NIL is the equivalent to false. An empty list, (), is a synonym for NIL.

## eq ##
To check if the arguments are both the same memory location or the same symbol one uses