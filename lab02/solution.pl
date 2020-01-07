% Place your solution here
mylen([], 0).
mylen([_|T], N) :-
    mylen(T, N1),
    N is N1+1.

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

gods([truth, lie, dipl]). % Список всех богов
godsay(pos(left, truth)).  % Левый сказал, что посередине бог правды
godsay(pos(center, dipl)). % Средний сказал, что он бог дипломатии
godsay(pos(right, lie)).  % Правый сказал, что посередине бог лжи
writepos(left, V, [V, _, _]).
writepos(center, V, [_, V, _]).
writepos(right, V, [_, _, V]).

rotate(left, right).
rotate(right, left).

solve :-
    gods(GodLst),
    List=[_, _, _],
    godsay(pos(center, Center)),
    (   Center==truth % Посередине может стоять любой бог
        % C=truth
    ;   Center==lie, % Только бог дипломатии может сказать, что он бог лжи
        writepos(center, dipl, List),
        godsay(pos(Truth, dipl)), % Известно что посередине бог дипломатии, кто назовёт его богом дипломатии будет богом правды
        writepos(Truth, truth, List),
        godsay(pos(Truth, TrueGod)),
        writepos(center, TrueGod, List)
    ;   Center==dipl,
        (   godsay(pos(Pos, truth)), % Посередине точно не бог правды, и тот, кто назовёт среднего богом правды врёт
            rotate(Pos, PPos),
            writepos(PPos, truth, List),
            godsay(pos(PPos, TrueGod)),
            writepos(center, TrueGod, List)
        ;   mypermute([lie, dipl], [G, _]),
            writepos(center, G, List) % Нельзя определить богов однозначно, но можно предположить варианты их расположения
        )
    ),
    mypermute(GodLst, List), !,
    writeln(List).
