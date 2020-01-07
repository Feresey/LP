mylen([], 0).
mylen([_|T], N) :-
    mylen(T, N1),
    N is N1+1, !.

mymember(X, [_|T]) :-
    mymember(X, T), !.
mymember(H, [H|_]).

myappend([], L, L).
myappend([X|L1], L2, [X|L3]) :-
    myappend(L1, L2, L3).

rm(X, [X|T], T).
rm(X, [M|T], [M|T1]) :-
    rm(X, T, T1), !.

mypermute([], []).
mypermute([X|T], R) :-
    rm(X, R, T1),
    mypermute(T, T1).

mysublist(List, T) :-
    myappend(Sublist, _, T),
    myappend(_, List, Sublist), !.

change(Itm, 0, [_|Res], [Itm|Res]).
change(Itm, N, [H|Lst], Res) :-
    N>0,
    N1 is N-1,
    change(Itm, N1, Lst, R),
    append([H], R, Res), !.

stdchange(Itm, Num, Lst, Res) :-
    Num>=0,
    length(HelpLst, Num),
    append(HelpLst, Tail, Lst),
    [_|TTail]=Tail,
    append(HelpLst, [Itm|TTail], Res).

cut(_, [], [], []).
cut(X, [H|Lst], L, R) :-
    (   H>X,
        cut(X, Lst, L, R1), !,
        myappend([H], R1, R)
    ;   H<X,
        cut(X, Lst, L1, R), !,
        myappend([H], L1, L)
    ;   H is X,
        cut(X, Lst, L, R)
    ).

cut([X|Lst], L, R) :-
    cut(X, Lst, L, R), !.

stdcut([X|Lst],L,R):-
    findall(Num,(member(Num,Lst),Num < X),L),
    findall(Num,(member(Num,Lst),Num > X),R).
