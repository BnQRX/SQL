/*Вывести образовательные программы, на которые для поступления необходимы предмет
«Информатика» и «Математика» в отсортированном по названию программ виде.*/
select name_program
FROM
    (SELECT name_program, subject_id
     FROM program
     JOIN program_subject using(program_id)
     JOIN subject using(subject_id)
     WHERE name_subject='Математика' OR name_subject='Информатика') AS program_subject
GROUP BY name_program
HAVING count(program_subject.subject_id)=2
ORDER BY name_program;

/*Посчитать количество баллов каждого абитуриента на каждую образовательную программу, 
на которую он подал заявление, по результатам ЕГЭ. В результат включить название образовательной программы,
фамилию и имя абитуриента, а также столбец с суммой баллов, который назвать itog. Информацию вывести 
в отсортированном сначала по образовательной программе, а потом по убыванию суммы баллов виде.*/
SELECT name_program, name_enrollee, sum(result) AS 'itog'
FROM enrollee
    join program_enrollee using(enrollee_id)
    join program using(program_id)
    join program_subject using(program_id)
        join enrollee_subject ON program_subject.subject_id=enrollee_subject.subject_id  and enrollee.enrollee_id=enrollee_subject.enrollee_id
GROUP BY name_program, name_enrollee
ORDER BY name_program, itog desc;

/*Вывести название образовательной программы и фамилию тех абитуриентов, которые подавали документы на эту образовательную программу, 
но не могут быть зачислены на нее. Эти абитуриенты имеют результат по одному или нескольким предметам ЕГЭ, необходимым для поступления
на эту образовательную программу, меньше минимального балла. Информацию вывести в отсортированном сначала по программам, 
а потом по фамилиям абитуриентов виде.*/
Select program.name_program, enrollee.name_enrollee
From program
   Join program_enrollee using (program_id)
   Join enrollee on program_enrollee.enrollee_id=enrollee.enrollee_id
   Join enrollee_subject on enrollee.enrollee_id=enrollee_subject.enrollee_id
   Join program_subject on program_enrollee.program_id=program_subject.program_id AND program_subject.subject_id=enrollee_subject.subject_id
Where enrollee_subject.result<program_subject.min_result
Order by program.name_program, enrollee.name_enrollee;

