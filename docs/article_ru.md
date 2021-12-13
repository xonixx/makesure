# Makesure
## 1. What is it?
## 2. Motivation
## 3. Idempotence
## 4. Why awk? - better shell

I personally have found that AWK is a surprisingly good alternative to shells for scripts bigger than average.
Why?

1. Portability (AWK is a part of POSIX)
2. Very clean syntax
3. Powerful associative arrays
4. Super-powerful string manipulations facilities
5. Easy shell interoperability

## 5. Interesting facts of awk: no GC, etc.

AWK - интерпретируемый язык. Он очень минималистичный. 
Скудный минимум фич включает строки, числа, функции, ассоциативные массивы, построчный I/O. 
Пожалуй, можно сказать что он содержит тот минимум фич меньше которого на нём невозможно было бы вовсе программировать.
Каноническая и очень увлекательная книжка TODO.

Удивительно, но язык AWK для своей реализации не требует GC. Впрочем, как и sh/bash.

Секрет тут в том, что в языке, грубо говоря, просто отсутствует возможность делать 'new'. Так, ассоциативный массив объявляется просто фактом использования соответствующей переменной 'как массива'. https://en.wikipedia.org/wiki/Autovivification

```awk
arr["a"] = "b"
```
 
Аналогично, переменная, с которой обращаются как с числом (`i++`) будет как-бы неявно объявлена числовым типом, и т.д.
Сделано это, очевидно, для того чтобы можно было писать как можно более компактный код в однострочниках, для чего многие из нас и привыкли использовать Awk.

Также из функции запрещено возвращать массив, можно только скалярное значение.

```awk
function f() {
  a[1] = 2
  return a # error
}

```
Но, можно передавать массив в функцию и заполнять его там
                                                 
```awk
BEGIN { 
  fill(arr)
  print arr[0] " " arr[1] 
}
function fill(arr,   i) { arr[i++] = "hello"; arr[i++] = "world" }
```

Еще одна интересная особенность. Все переменные по умолчанию глобальны. Однако, если добавить переменную в параметры функции (как `i` выше) - она станет локальной. Javascript работает похожим образом, хотя там есть еще `var`/`let`/`const`.
На практике принято отделять "реальные" параметры функции от "локальных" дополнительными пробелами для понятности.

Собственно, использование локальных переменных является механизмом автоматического освобождения ресурсов. Небольшой [пример](https://github.com/xonixx/gron.awk/blob/main/gron.awk#L81).
```awk
function NUMBER(    res) {
  return (tryParse1("-", res) || 1) &&
    (tryParse1("0", res) || tryParse1("123456789", res) && (tryParseDigits(res)||1)) &&
    (tryParse1(".", res) ? tryParseDigits(res) : 1) &&
    (tryParse1("eE", res) ? (tryParse1("-+",res)||1) && tryParseDigits(res) : 1) &&
    asm("number") && asm(res[0])
}
```

В функции `NUMBER` происходит разбор числа. `res` является временным массивом, который будет удалён при выходе из функции автоматически. 


Еще из интересного. 

```
$ node -e 'function sum(n) { return n == 0 ? 0 : n + sum(n-1) }; console.info(sum(100000))'
[eval]:1
function sum(n) { return n == 0 ? 0 : n + sum(n-1) }; console.info(sum(100000))
                  ^

RangeError: Maximum call stack size exceeded
    at sum ([eval]:1:19)
    at sum ([eval]:1:43)
    at sum ([eval]:1:43)
    at sum ([eval]:1:43)
    at sum ([eval]:1:43)
    at sum ([eval]:1:43)
    at sum ([eval]:1:43)
    at sum ([eval]:1:43)
    at sum ([eval]:1:43)
    at sum ([eval]:1:43)
```

Тот же Gawk прожует миллион и не поперхнется:
   
```
$ gawk 'function sum(n) { return n == 0 ? 0 : n + sum(n-1) }; BEGIN { print sum(1000000) }'
500000500000
```


## 6. IntelliJ-awk
## 7. Dog fooding
## 8. Testing in different awks, goawk
## 9. Design principles, why Turing completeness is not good
## 10. Alternatives overview
## 11. Process of designing features: script -> lib, goal_glob -> glob
## 12. Parsing in Awk vs reparsing. On importance of starting limited
## 13. Ms time precision on BSD problem. Rant on BSD
## 14. On necessity of awk compilation build step (cat in shellExec)
## 15.
## 16.