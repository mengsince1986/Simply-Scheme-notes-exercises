;;; A test program for database-mz

(load-db "name-age.scm")

(sort (lambda (r1 r2) (< (get r1 'age) (get r2 'age))))




