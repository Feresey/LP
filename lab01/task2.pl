:- ['one.pl'].
% :- ['tst2.pl'].
:- ['task1.pl'].

group(X, L) :-
    findall(Z, student(X, Z), L).

sum([], 0). % Суммирование всех значений списка (если все элементы - числа) 
sum([H|L], S) :-
    sum(L, Re),
    number(H),
    S is Re+H.

tonum(_, [], _). % Создание из фамилий списка оценок
tonum(S, [H|T], R) :-
    grade(H, S, N),
    tonum(S, T, Re),
    myappend(Re, [N], R), !.

maxlst(Subj, L) :- % Проверка, содержит ли список фамилий всех возможных студентов
    grade(X, Subj, _),
    not(mymember(X, L)).

sr(S, R) :- % Среднеарифметическое всех оценок по предмету
    findall(X, grade(X, S, _), Lc),
    tonum(S, Lc, L), !,
    sum(L, Sum),
    mylen(L, Len),
    Len>0,
    R is Sum/Len.

middle(S, Res) :- % Создан только для наглядности вывода, сам вывод бесконечный из за того, что уже выведенные предметы обрабатываются циклично
    grade(_, S, _),
    sr(S, Res).

singleItems([], X, X). % Результирующий список содержит только уникальные элементы заданного списка
singleItems([H|List], Prev, Res) :-
    (   not(mymember(H, Prev)),
        singleItems(List, [H|Prev], Res), !
    ;   mymember(H, Prev),
        singleItems(List, Prev, Res), !
    ).


inGroup(_, [], []). % Результатом является список всех студентов, принадлежащих указанной группе, и которые есть в заданном списке
inGroup(Group, [H|List], Res) :-
    (   student(Group, H),
        inGroup(Group, List, Res1),
        append(Res1, [H], Res)
    ;   not(student(Group, H)),
        inGroup(Group, List, Res)
    ).
    

groupNotPass(Group, N) :- % Поиск не сдавших студентов для указанной группы
    findall(Name, grade(Name, _, 2), L1),
    singleItems(L1, [], L2),
    inGroup(Group, L2, L), !,
    mylen(L, N).

subjNotPass(Subj, N) :- % Находит количество не сдавших студентов для указанного предмета
    findall(Name, grade(Name, Subj, 2), L),
    mylen(L, N).
