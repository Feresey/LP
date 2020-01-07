%pipl(ID, Name_of_person). %Для корректной обработки людей с одинаковыми именами
%mother(Mother_ID, Child_ID).
%father(Father_ID, Child_ID).

% Дополнительно для корректной обработки пар без детей, 
% был введён "фиктивный" ребёнок, с отрицательным индексом.
% Так же для определения пола были использованы факты father/mother, где в качестве ребёнка указывался 0
:- ['relatives.pl']. % файл с отношениями родства
:- op(228, fx, print). 
:- op(120, xf, ?).

male(X) :-
    father(X, _).

female(X) :-
    mother(X, _).

tesha(Person, Tesha) :-
    fam(husband, Person, Wife),
    fam(mother, Tesha, Wife).

sibling(Person, Sibling) :-
    (   father(Parent, Person),
        father(Parent, Sibling)
    ;   mother(Parent, Person),
        mother(Parent, Sibling)
    ),
    Person\=Sibling,
    Sibling\=0.

fam(husband, Husband, Wife) :-
    father(Husband, Child),
    Child\=0,
    mother(Wife, Child), !.

fam(wife, Wife, Husband) :-
    father(Husband, Child),
    Child\=0,
    mother(Wife, Child), !.

fam(brother, Brother, Y) :-
    sibling(Brother, Y),
    male(Brother).

fam(sister, Sister, Y) :-
    sibling(Sister, Y),
    female(Sister).

fam(father, Father, Child) :-
    father(Father, Child),
    Child\=0, !.

fam(mother, Mother, Child) :-
    mother(Mother, Child),
    Child\=0, !.

fam(parent, Parent, Child) :-
    (   fam(mother, Parent, Child)
    ;   fam(father, Parent, Child)
    ).

fam(son, Child, Parent) :-
    fam(parent, Parent, Child),
    male(Child).

fam(daughter, Child, Parent) :-
    fam(parent, Parent, Child),
    female(Child).

fam(child, Child, Parent) :-
    fam(parent, Parent, Child).

is_fam(X) :-
    member(X, [father, mother, sister, brother, son, daughter, husband, wife]).

prolong([X|T], [Y, X|T]) :-
    fam(_, X, Y),
    not(member(Y, [X|T])).

relative(From_person, To_person, Res) :-
    search([[To_person]], From_person, Ress),
    transform(Ress, Res).

% поиск в ширину
search([[X|T]|_], X, [X|T]). % конец рекурсии, необходимый путь найден
search([P|QI], Search_Elem, Res) :-
    findall(Z, prolong(P, Z), From_P),
    append(QI, From_P, Q0), % вместо Р добавляем в конец списка все пути из него
    search(Q0, Search_Elem, Res), !.
search([_|T], Y, L) :-
    search(T, Y, L).

transform([_], []) :- !. %  устанавливает степени родства между каждыми двумя элементами 
transform([First, Second|T], Res) :-
    fam(Relation, First, Second),
    Res=[Relation|Ress],
    transform([Second|T], Ress), !.

print(X) :-
    pipl(X, Y),
    Y\=0,
    write(Y).

parse(Input, Res) :-
    split_string(Input, ", `", "`", Res).


create_names([N, S|List], Namelist) :-
    concat(N, " ", NN),
    concat(NN, S, Name),
    (   pipl(Num, Name),
        append([Num], Res2, Namelist),
        create_names(List, Res2)
    ;   append([N], Res2, Namelist),
        create_names([S|List], Res2)
    ), !.
create_names([Last], [Last]).

?(Input) :-
    parse(Input, List),
    create_names(List, Names),
    writeln(Names),
    question(Names, Res),!,
    nl,
    read(Line),
    Line?Res.

Line?Prev :-
    parse(Line, List),
    create_names(List, Names),
    writeln(Names),
    question([Prev|Names], _),!.
    % nl,
    % read(Line),
    % Line?Res.

question_word(X) :-
    member(X, ["how", "who", "How", "Who"]).

quantity(X) :-
    member(X, ["much", "many"]).

purals(X) :-
    member(X, [sisters, brothers, sons, daughters]).
pural(sister, sisters).
pural(brother, brothers).
pural(son, sons).
pural(daughter, daughters).

help_word(X) :-
    member(X, ["do", "does"]).

have_has(X) :-
    member(X, ["have", "has"]).

is(X) :-
    member(X, ["is", "Is"]).

his_her(X) :-
    member(X, [his, her, he, she]).

% "Who is Анна /Сорокина/`s son" ? .
question(List, Res) :-
    List=[A, B, C, D, E1],
    question_word(A),
    B=="is",
    D=="s",
    string_to_atom(E1, E),
    is_fam(E),
    fam(E, Res, C),
    print Res,
    write(" is "),
    print C,
    write("'s "),
    write(E).

% "How many brothers does Павел /Милько/ have" ? .
question(List, Res) :-
    List=[A, B, C1, D, Res, F],
    question_word(A),
    string_to_atom(C1, C),
    quantity(B),
    purals(C),
    help_word(D),
    have_has(F),
    pural(C2, C),
    findall(X, fam(C2, X, Res), T),
    length(T, Len), !,
    print Res,
    write(" have "),
    write(Len),
    (   Len==1,
        write(" ")
    ;   write("s ")
    ),
    write(C2), !.

%how many brothers does he have ?
question(List, Prev) :-
    List=[Prev, A, B, C1, D, E1, F],
    question_word(A),
    string_to_atom(C1, C),
    string_to_atom(E1, E),
    quantity(B),
    purals(C),
    help_word(D),
    his_her(E),
    have_has(F),
    pural(C2, C),
    findall(X, fam(C2, X, Prev), T),
    length(T, Res), !,
    print Prev,
    write(" have "),
    write(Res),
    (   Res==1,
        write(" ")
    ;   write("s ")
    ),
    write(C2), !.

% is *name* *name* s son?
% "is Роман /Гамалей/ Павел /Милько/`s brother" ? .
question(List, B) :-
    List=[A, B, C, D, E1],
    is(A),
    string_to_atom(E1, E),
    D=="s",
    is_fam(E),
    fam(E, B, C), !.

% is *name* his son
question(List, Prev) :-
    List=[Prev, A, B, C, D1],
    is(A),
    string_to_atom(D1, D),
    his_her(C),
    is_fam(D),
    fam(D, B, Prev), !.

% who is her brother
question(List, Res) :-
    List=[Prev, A, B, C1, D1],
    question_word(A),
    string_to_atom(D1, D),
    string_to_atom(C1, C),
    is(B),
    his_her(C),
    is_fam(D),
    fam(D, Res, Prev),
    print Res,
    write(" is "),
    print Prev,
    write("'s "),
    write(D).

start:-
    "Who is Максим /Гамалей/`s brother" ? .