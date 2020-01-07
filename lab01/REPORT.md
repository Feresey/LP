# Отчет по лабораторной работе №1

## Работа со списками и реляционным представлением данных

## по курсу "Логическое программирование"

### студент: Милько Павел Алексеевич

## Результат проверки

| Преподаватель     | Дата         |  Оценка       |
|-------------------|--------------|---------------|
| Сошников Д.В. |              |               |
| Левинская М.А.|  24/11/18    |       5-      |

> *Комментарии проверяющих (обратите внимание, что более подробные комментарии возможны непосредственно в репозитории по тексту программы)*

## Введение

В общем случае список в прологе представляет собой абстрактный тип данных, задающий набор значений. Притом значения могут быть любыми (включая списки). Длина списка и степень вложенности теоретически не ограничены.

В прологе основным способом обработки списков (в отличие от императивных языков, где более рациональны итерации), является рекурсия. Это задаёт основные ограничения (конец рекурсии). Такое условие часто прописывается отдально. Например для предиката вычисления длины списка таким условием является `len([],0).`.

Списки в прологе похожи на структуру данных "связный список". Связный список так же состоит из узлов, а каждый узел содержит значение и ссылку на последующий элемент, в качестве пустой ссылки в прологе выступет `[]`. Легко заметить, всё точно как в прологе, нельзя обратиться к какому-либо элементу списка, не пройдя через все предыдущие.

Так же можно представить список пролога в виде дерева:

 ```text
 .---.---.---[]
 |   |   |
 a   b   c
 ```

То есть, список представляет из себя конкатенацию элемента (головы) и списка (хвоста). На прологе данное дерево можно записать как `[a|[b|[c|[]]]]`.

<!-- Опишите своими словами, чем списки в языке Пролог отличаются от принятых в императивных языках подходов к хранению данных. На какие структуры
данных в традиционных языках похожи списки в Прологе? -->

## Задание 1.1: Предикат обработки списка

`change(Itm,N,List,Res)` --- Замена N-го элемента списка на **Itm** (начало нумерации с 0).

Примеры использования:

```prolog
?- change(a,2,[s,f,sb,c,vg,'AAA'],Res).
Res = [s, f, a, c, vg, 'AAA'].

?- change(a,4,[s,s,s],Res).
false.
```

Реализация:

```prolog
change(Itm,0,[_|Lst],Res):-
    myappend([Itm],Lst,Res),!.
change(Itm,N,[H|Lst],Res):-
    N1 is N - 1,
    change(Itm,N1,Lst,R),
    myappend([H],R,Res),!.

%либо через стандартные предикаты:

stdchange(Itm, Num, Lst, Res) :-
    Num>=0,
    length(HelpLst, Num),
    append(HelpLst, Tail, Lst),
    [_|TTail]=Tail,
    append(HelpLst, [Itm|TTail], Res).
```

Существует более простая реализация: change(Itm,0,[_|Lst],[Itm|Lst]) без использования предиката append.
**Реализация при помощи стандартных предикатов будет различаться только в замене предиката `myappend` на стандартный `append`.**

Сначала отрабатывает второе определение предиката, при достижении конца рекурсии (N == 0) отработает первое определение, и "отрежется" N-ый элемент.

Затем, с помощью предиката `myappend` создастся новый список, где в голове будет **Itm**, а в хвосте окажется остальная часть списка, которую заменять не надо.
<!-- Опишите своими словами принцип работы предиката обработки списка. -->

## Задание 1.2: Предикат обработки числового списка

`cut(Lst,Smaller,Bigger)` --- Разделение списка на два относительно первого элемента (по принципу "больше-меньше").

Примеры использования:

```prolog
?-  cut([2,3,1,0,9,12,2,11,-11,0 ,4],L,R).
L = [1, 0, -11, 0],
R = [3, 9, 12, 11, 4].

?- cut([3,3,1,0,9],L,R).
L = [1, 0],
R = [9].

?- cut([],L,R).
false.

?- cut([3,4,5,6,3],L,R).
L = [],
R = [4, 5, 6].

?- cut([99,99,99],L,R).
L = R, R = [].

?- cut([3,2],L,R).
L = [2],
R = [].

?- cut([3,4,4,4],L,R).
L = [],
R = [4, 4, 4].
```

Реализация:

```prolog
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
    cut(X, Lst, L, R).

%либо через стандартные предикаты:

stdcut([X|Lst],L,R):-
    findall(Num,(member(Num,Lst),Num < X),L),
    findall(Num,(member(Num,Lst),Num > X),R).

```

### Практическое применение реализованных предиктаов

```prolog
?- L = [1,2,3,4,5,6,7],nl,nl,
write("List is "), write(L), mylen(L,N),
write(", its length is "), write(N),nl,
write("change element 3 to \'a\', "),
change(a,3, L, X), write("X = "), write(X), nl,
write("remove 3 from list, "),
rm(3, L, T), write("new list is: "), write(T),nl,
write("its length is "), mylen(T, N1), write(N1), nl,
write("is "), write(1), write(" member of "),
write(T), write("? "),mymember(1,T).


List is [1,2,3,4,5,6,7], its length is 7
change element 3 to 'a', X = [1,2,3,a,5,6,7]
remove 3 from list, new list is: [1,2,4,5,6,7]
its length is 6
is 1 member of [1,2,4,5,6,7]?
L = [1, 2, 3, 4, 5, 6, 7],
N = 7,
X = [1, 2, 3, a, 5, 6, 7],
T = [1, 2, 4, 5, 6, 7],
N1 = 6.
```

**Реализация при помощи стандартных предикатов будет различаться только в замене предиката `myappend` на стандартный `append`.**

Предикат `cut/3` существует только для удобства использования (нелогично передавать голову списка как отдельную переменную)

В предикате `cut/4`, первый параметр, **X**, это голова списка, по этому значению и будут сортироваться элементы.

`cut/4` по сути содержит в себе 3 различных условия: если текущий элемент больше/меньше/равен элементу **X**.

В случае, если текущий элемент больше, рекурсивно вызывается `cut/4`, а затем этот элемент добавляется в список бОльших элементов.

Случай меньше эквивалентен, за исключением того, что элемент добавляется в список меньших элементов.

В случае если текущий элемент равен **X**, он пропускается.

строка `cut(_,[],_,_).` необходама для корректного завершения рекурсии.
 <!-- Опишите предикат по образцу выше -->

## Задание 2: Реляционное представление данных

<!-- Опишите, в чем преимущества и недостатки реляционного представления в целом, и конкретного представления, которое вы использовали. -->

Отличие реляционного представления от традиционного представления в виде таблицы состоит в том, что порядок следования столбцов в отношении не важен.

Из этого вытекают *плюсы* этой модели:

+ Простота. В реляционной модели всего одна информационная конструкция, которая формализует табличное представление данных, которое более привычно для восприятия.

+ Теоретическое обоснование. Наличие теоретически обоснованных методов нормализации отношений позволяет получать БД с заданными характеристиками.

+ Независимость данных. При необходимости внесения правок в реляционную БД, это не потребует много усилий и не вызовет сложностей.

Из плюсов, в частности из независимости данных, вытекают *минусы*:

+ Низкая скорость при выполнении операции соединения.

+ Большой расход памяти для представления реляционной БД.

<!-- Опишите принцип реализации всех предикатов, осуществляющих запросы к данным. -->

---

`sum` - Суммирование всех значений списка (если все элементы - числа)

Предикат запускается рекурсивно, на каждой итерации у списка отрезается голова, при достижении конца рекурсии (вызов предиката для пустого описка) отрезанные значения суммируются.

Пример:

```prolog
?- sum([1,2,3,4],S).
S = 10.
```

---

`tonum` - Создание из фамилий списка оценок

Предикат запускается рекурсивно, для каждой фамилии и предмета в результирующий список добавляется соответствующая оценка.

Пример:

```prolog
?- tonum('LP',['Сидоров'],L).
L = [4].
```

---

`maxlst` - Проверка, содержит ли список фамилий всех возможных студентов

Есть ли ещё студент,получивший оценку по данному предмету, но отсутствующий в списке. (Для каждого студента, которого можно добавить в список, будет выводиться true)

Пример:

```prolog
?- maxlst('LP',['Сидоров']).
true ;
true ;
true .
```

---

`sr` - Среднеарифметическое всех оценок по предмету

Используются все ранее описанные предикаты.

Составляется список из фамилий тех студентов, кто получил оценку по данному предмету, затем вызывается предикат `tonum`, создающий список оценок.

Уже для списка оценок считается длина и сумма всех элементов, затем следует ответ.

Пример:

```prolog
?- sr('LP',Num).
Num = 3.9642857142857144.
```

---

`middle` - Создан только для наглядности вывода, т.к. вызываемый предикат определяет неизвестное название предмета по первому студенту в списке.

Пример:

```prolog
?- middle(S,Res).
S = 'LP',
Res = 3.9642857142857144 ;
S = 'MTH',
Res = 3.6785714285714284 ;
S = 'FP',
Res = 3.892857142857143 ;
S = 'INF',
Res = 3.5714285714285716 ;
S = 'ENG',
Res = 4.178571428571429 ;
S = 'PSY',
Res = 3.607142857142857 .
```

---

`singleItems` - Результирующий список содержит только уникальные элементы заданного списка.

Если элемента нет в промежуточном списке **Prev**, то он в него добавляется

Пример:

```prolog
?- singleItems([1,1,1,2,4,3,3,3],[],Res).
Res = [3, 4, 2, 1].
```

---

`inGroup` - Результатом является список всех студентов, принадлежащих указанной группе, и которые есть в заданном списке.

Если студент принадлежит искомой группе, предикат вызывается рекурсивно. Если студент не принадлежит группе, он пропускается. При достижении конца рекурсии результирующий список составляется из отсечённых ранее значений.

Пример:

```prolog
?- inGroup(101,['Сидоров'],Res).
Res = ['Сидоров'] .

?- inGroup(101,['Сидор'],Res).
Res = [] .
```

---

`groupNotPass` - Поиск не сдавших студентов для указанной группы

Сначала составляется список не сдавших студентов по всем предметам. Затем в этом списке убираются дублирующиеся фамилии. Получившийся список обрабатывается предикатом `notPass`, составляющий из заданного списка список не сдавших студентов, принадлежащих только указанной группе. Длина этого списка и есть результат работы предиката.

Пример:

```prolog
?- groupNotPass(101,Num).
Num = 2.

?- groupNotPass(102,Num).
Num = 4.

?- groupNotPass(103,Num).
Num = 3.
```

---

`subjNotPass` - Находит количество не сдавших студентов для указанного предмета

Составляется список из всех студентов, не сдавших указанный предмет, вычисляется его длина.

Пример:

```prolog
?- subjNotPass('LP',Num).
Num = 3.

?- subjNotPass('ENG',Num).
Num = 1.

?- subjNotPass('PHAHA',Num).
Num = 0.

?- subjNotPass('PSY',Num).
Num = 5.
```

## выводы

Работать со списками с помощью языка Prolog легче, чем с помощью императивных языков программирования (например, С++). Prolog близок к естественным языкам, поэтому программа (факты, предикаты) и ее вызовы (запросы) легко читаются.

В данной лабораторной работе я научился работать со стандартными предикатами обработки списков и реализовал их самостоятельно.

<!-- Сформулируйте *содержательные* выводы по лабораторной работе. Чему она вас научила? Над чем заставила задуматься? Помните, что несодержательные выводы -
самая частая причина снижения оценки за лабораторную. -->