join([], []).
join([H|List], Res) :-
    is_list(H),
    join(List, Ress),
    join(H, H_simple),
    append(H_simple, Ress, Res), !.
join([H|L], [H|R]) :-
    join(L, R), !.

calculate([H], Res) :-
    join(H, Res).

calculate(List, Res) :-
    member(Oper, [*, /, +, -]), % Порядок операторов определяет их приоритет
    append(H, T, List), % Разделение списка на 2 части: в первой должна содержаться тройка
    append(Head, [L, Oper, R], H), % Разделение списка на 3 части: слева от тройки, справа от тройки и сама тройка
    append(Head, [[Oper, L, R]|T], Ress), % запись всего этого в промежуточный результат (когда обработаны не все тройки)
    calculate(Ress, Res), !.
