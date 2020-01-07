#!/usr/bin/env python3
import sys

if len(sys.argv) < 2:
    print('usage:: ./par.py /path/to/file.ged (default output to stdout)')
    print('usage:: ./par.py /path/to/file.ged /path/to/output/file.pl')
    sys.exit(1)

Out = open(sys.argv[2] if len(sys.argv) > 2 else "/dev/stdout", "w")
In = open(sys.argv[1], 'r')
relatives = []


Write = lambda Fact_name, items: print("{}({}).".format(Fact_name, ", ".join(items)),file=Out)


def WriteChilds(Fact_name, item):
    for i in relatives:
        if i[item]:
            for child in i['CHIL']:
                Write(Fact_name, [i[item], child])


def main():
    global relatives
    names = []
    fictive_child = 0
    male = []
    female = []
    ID = ''

    for line in In.readlines():  # Цикл для каждой строки GEDCOM файла
        l = line.split()

        if l[-1] == 'INDI':
            # Поиск уникального ID человека
            ID = l[1][2:-1]
            if len(names) and is_child:
                if names[-1][2] == 'F':
                    female.append(['mother', [names[-1][0], '0']])
                elif names[-1][2] == 'M':
                    male.append(['father', [names[-1][0], '0']])
            is_child = True
        elif l[1] == 'NAME' and ID:
            # Элемент списка: ID и имя человека
            names.append(
                [
                    ID,
                    "\'"
                    + ''.join(i if i != "\'" else "\\\'"
                              for i in ' '.join(l[2:]))
                    + "\'"
                ])
            Write('pipl', names[-1])
        elif l[1] == 'SEX':
            names[-1].append(l[2])
        elif l[1] == 'FAMS':
            is_child = False
        elif l[-1] == 'FAM':
            # Я не знаю как иначе описать пару муж/жена, у которых нет детей,
            # поэтому для построения связей будут использованы
            # фиктивные дети с отрицательным ID
            if len(relatives) :
                if len(relatives[-1]['CHIL']) == 0:
                    fictive_child -= 1
                    relatives[-1]['CHIL'].append(str(fictive_child))
            # Шаблон словаря родственных связей
            relatives.append({"HUSB": '', "WIFE": '', "CHIL": []})

        # дозапись элементов в последнюю родственную связь
        elif l[1] == 'HUSB' or l[1] == 'WIFE':
            relatives[-1][l[1]] = l[2][2:-1]
        elif l[1] == 'CHIL':
            relatives[-1]['CHIL'].append(l[2][2:-1])

    for i in female:
        Write(*i)

    WriteChilds('mother', 'WIFE')  # Построение связей мать - ребёнок
    WriteChilds('father', 'HUSB')  # Построение связей отец - ребёнок

    for i in male:
        Write(*i)

    In.close()
    Out.close()


if __name__ == '__main__':
    sys.exit(main())
