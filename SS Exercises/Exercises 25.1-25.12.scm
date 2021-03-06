; Exercises 25.1-25.12

; 25.1 The “magic numbers” 26 and 30 (and some numbers derived from them) appear many times in the text of this program. It’s easy to imagine wanting more rows or columns.

; Create global variables total-cols and total-rows with values 26 and 30 respectively.  Then modify the spreadsheet program to refer to these variables rather than to the numbers 26 and 30 directly. When you’re done, redefine total-rows to be 40 and see if it works.

; solution: spread-ex25.scm
; * create global variables *total-cols* and *total-rows*
; * replace 30 and 29 in all the procedures with *total-rows*
; * replace 26 and 25 in all the procedures with *total-cols*

; **********************************************************

; 25.2 Suggest a way to notate columns beyond z. What procedures would have to change to accommodate this?

; solution: spread-ex25.scm

; to notate columns beyond z we can

; modify the alphabet vector, add more elements after z
(define alphabet
  '#(a b c d e f g h i j k l m n o p q r s t u v w x y z
       aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at au av aw ax ay az))

; we also need to modify the following procedures in:
; 1. "Spreasheet size" section
     *total-cols* ; less than (length alphabet)
; 2. "Cell names" section
     cell-name?
     cell-name-column
     cell-name-row
; 3. "Utility" section
     letter?
; 4. "Printing the screen" section
     display-value

; **********************************************************

; 25.3 Modify the program so that the spreadsheet array is kept as a single vector of 780 elements, instead of a vector of 30 vectors of 26 vectors. What procedures do you have to change to make this work? (It shouldn’t be very many.)

; solution: spread-ex25.scm

;to make the spreadsheet array kept as a single vector of 780 elements, we need to change:

; 1. "Cells" section
     *the-spreadsheet-array*
     global-array-lookup
     init-array

; **********************************************************

; 25.4 The procedures get-function and get-command are almost identical in struc- ture; both look for an argument in an association list. They differ, however, in their handling of the situation in which the argument is not present in the list. Why?

; answer: to make the program robust, it's necessary to add error message in get-function.
; If the user input a function that's not included in *the-functions*, the program would stop and return an error by scheme itself. A specified error message would help users debug the program.
; While if the user input a command that's not included in *the-commands*, the program will still continue in `process-command` and treat the user input as a formula which will invoke `get-function`. So it's not necessary to add specified error message for `get-command`.

; **********************************************************

; 25.5 The reason we had to include the word id in each cell ID was so we would be able to distinguish a list representing a cell ID from a list of some other kind in an expression. Another way to distinguish cell IDs would be to represent them as vectors, since vectors do not otherwise appear within expressions. Change the implementation of cell IDs from three-element lists to two-element vectors:

(make-id 4 2)
; #(4 2)

; Make sure the rest of the program still works.

; solution: spread-ex25.scm
; modify the procedures in Cell IDs section

(define (make-id col row)
  (vector col row))

(define (id-column id)
  (vector-ref id 0))

(define (id-row id)
  (vector-ref id 1))

(define (id? x)
  (and (vector? x)
       (= (vector-length x) 2)))

; **********************************************************

; 25.6 The put command can be used to label a cell by using a quoted word as the “formula.” How does that work? For example, how is such a formula translated into an expression? How is that expression evaluated? What if the labeled cell has children?

; answer: When put command take a quoted word as the formula:
; 1. put command calls put-formula-in-cell with the quoted word.
; 2. put-formula-in-cell calls put-expr.
; 3. put-expr calls pin-down which translates the quoted word into expression.
; 4. pin-down takes the label as its first argument. Since (word? formula) is true, pin-down returns the quoted word back to put-expr.
; 5. put-expr:
;    * removes the labeled cell from all its former parents,
;    * sets the labeled cell's expression with the quoted word,
;    * sets the cell's parents as an empty list,
;    * invoke figure with the label cell's id
; 6. figure invokes setvalue with the label cell's id and its expression--quoted  word.
; 7. setvalue calls figure for all the children of the labeled cell.
; 8. figure sets all its children's value into '(), since all-evaluated? returns false.

; **********************************************************

; 25.7 Add commands to move the “window” of cells displayed on the screen without changing the selected cell. (There are a lot of possible user interfaces for this feature; pick anything reasonable.)

; solution:

; first addd window moving commands in *the-commands*:

(define *the-commands*
  (list (list 'p prev-row)
        (list 'n next-row)
        (list 'b prev-col)
        (list 'f next-col)
        (list 'select select)
        (list 'window-p win-p)
        (list 'window-n win-n)
        (list 'window-b win-b)
        (list 'window-f win-f)
        (list 'put put)
        (list 'load spreadsheet-load)))

; then define the matching procedure one by one.

; Window selection commands: window-f, window-b, window-n, window-p:

(define (win-p delta)
  (let ((row (id-row (screen-corner-cell-id))))
    (if (< (- row delta) 1)
        (error "Already shown the top row")
        (begin (set-corner-row! (- row delta))
               (print-screen)))))

(define (win-n delta)
  (let ((row (id-row (screen-corner-cell-id))))
    (if (> (+ row delta 19) *total-rows*)
        (error "Already shown the bottom row")
        (begin (set-corner-row! (+ row delta))
               (print-screen)))))

(define (win-b delta)
  (let ((col (id-column (screen-corner-cell-id))))
    (if (< (- col delta) 1)
        (error "Already shown the left-most column")
        (begin (set-corner-column! (- col delta))
               (print-screen)))))

(define (win-f delta)
  (let ((col (id-column (screen-corner-cell-id))))
    (if (> (+ col delta 5) *total-cols*)
        (error "Already shown the right-most column")
        (begin (set-corner-column! (+ col delta))
               (print-screen)))))

**********************************************************
; 25.8 Modify the put command so that after doing its work it prints

; 14 cells modified

; (but, of course, using the actual number of cells modified instead of 14). This number may not be the entire length of a row or column because put doesn’t change an existing formula in a cell when you ask it to set an entire row or column.

; solution: modify the PUT section as following

(define (put formula . where)
  (put-helper formula where 0))

(define (put-helper formula where modified-num)
  (cond ((null? where)
         (begin (display-status (+ 1 modified-num))
                (put-formula-in-cell formula (selection-cell-id))))
        ((cell-name? (car where))
         (begin (display-status (+ 1 modified-num))
                (put-formula-in-cell formula (cell-name->id (car where)))))
        ((number? (car where))
         (begin (display-status (if (null? formula)
                                    *total-cols*
                                    (noval-cells (car where))))
                (put-all-cells-in-row formula (car where))))
        ((letter? (car where))
         (begin (display-status (if (null? formula)
                                    *total-rows*
                                    (noval-cells (car where))))
                (put-all-cells-in-col formula (letter->number (car where)))))
        (else (error "Put it where?")))
  )

(define (display-status num)
  (newline)
  (display "status: ")
  (display num)
  (if (> num 1)
      (display " cells modified")
      (display " cell modified")))

(define (noval-cells row-or-col)   ; return the number of the cells which has no values
  (if (number? row-or-col)
      (noval-row-cells row-or-col *total-cols* 0)
      (noval-col-cells row-or-col *total-rows* 0)))

(define (noval-row-cells row total-cells noval-cell-num)
  (cond ((= total-cells 0) noval-cell-num)
        ((null? (cell-value (make-id total-cells row)))
         (noval-row-cells row (- total-cells 1) (+ noval-cell-num 1)))
        (else (noval-row-cells row (- total-cells 1) noval-cell-num))))

(define (noval-col-cells col total-cells noval-cell-num)
  (cond ((= total-cells 0) noval-cell-num)
        ((null? (cell-value (make-id (letter->number col) total-cells)))
         (noval-col-cells col (- total-cells 1) (+ noval-cell-num 1)))
        (else (noval-col-cells col (- total-cells 1) noval-cell-num))))

; **********************************************************

; 25.9 Modify the program so that each column remembers the number of digits that should be displayed after the decimal point (currently always 2). Add a command to set this value for a specified column. And, of course, modify print-screen to use this information.

; solution: spread-ex25.scm

;; Column decimal digit command

(define (col-decimal num . where)
  (let ((col (if (null? where)
                 (id-column (selection-cell-id))
                 (letter->number (car where)))))
    (if (and (> col 0) (< col *total-cols*))
        (set-col-decimal-digit! col num)
        #f)))

;; Column decimal digit recorder

(define (init-decimal-digits vec digit index)  ; constructor
  (if (= index 0)
      vec
      (begin (vector-set! vec (- index 1) (vector (number->letter index) digit))
             (init-decimal-digits vec digit (- index 1)))))

(define *column-decimal-digits* (init-decimal-digits (make-vector *total-cols*)
                                                     2  ; initial decimal digit
                                                     *total-cols*))

(define (col-decimal-digit col)  ; selector
  (vector-ref (vector-ref *column-decimal-digits* (- col 1))
              1))

(define (set-col-decimal-digit! col digit)
  (vector-set! (vector-ref *column-decimal-digits* (- col 1))
               1
               digit))

;; also modified related procedures in Print section and Command section

; **********************************************************

; 25.10 Add an undo command, which causes the effect of the previous command to be nullified. That is, if the previous command was a cell selection command, undo will return to the previously selected cell. If the previous command was a put, undo will re-put the previous expressions in every affected cell. You don’t need to undo load or exit commands. To do this, you’ll need to modify the way the other commands work.

; solution: spread-ex25.scm

; command==log-undo-cmd/log-undo-put-cmd==>*undo-data*
; undo==>*undo-data*

;;; undo data

(define (init-undo-data data)
  (init-undo-data-helper data (- (vector-length data) 1)))

(define (init-undo-data-helper data index)
  (if (< index 0)
      data
      (begin (vector-set! data index null)
             (init-undo-data-helper data (- index 1)))))

;; *undo-cmd-data*

(define *undo-cmd-data* (vector null null))

;; *undo-put-data*

(define *undo-put-data*
  (init-undo-data (make-vector (* *total-rows* *total-cols*))))

;;; log undo command --exercise 25.10

(define (log-undo-cmd procedure arg-lst)
  (init-undo-data *undo-cmd-data*)
  (init-undo-data *undo-put-data*)
  (vector-set! *undo-cmd-data* 0 procedure)
  (vector-set! *undo-cmd-data* 1 arg-lst))

(define (log-undo-put expr cell-id)
  (let ((col (id-column cell-id))
        (row (id-row cell-id)))
    (vector-set! *undo-put-data*
                 (global-array-index col row)
                 (list expr cell-id))))

;; undo command

(define (undo anything)  ; the argument allows users use undo instead of (undo)
  (if (null? (vector-ref *undo-cmd-data* 0))
      (if (null-data? *undo-put-data* (- (vector-length *undo-put-data*) 1))
          (begin (newline)
                 (display "already the oldest command"))
          (undo-put))
      (apply (vector-ref *undo-cmd-data* 0)
             (vector-ref *undo-cmd-data* 1))))

(define (null-data? data index)
  (cond ((< index 0) #t)
        ((null? (vector-ref data index))
         (null-data? data (- index 1)))
        (else #f)))

(define (undo-put)
 (undo-put-helper *undo-put-data*
                  (- (vector-length *undo-put-data*) 1)))

(define (undo-put-helper data index)
  (cond ((< index 0) 'done)
        ((null? (vector-ref data index))
         (undo-put-helper data (- index 1)))
        (else (begin (apply put-formula-in-cell (vector-ref *undo-put-data* index))
               (undo-put-helper data (- index 1))))))

; and modify the other commands respectively.

; **********************************************************

; 25.11 Add an accumulate procedure that can be used as a function in formulas. Instead of specifying a sequence of cells explicitly, in a formula like

; (put (+ c2 c3 c4 c5 c6 c7) c10)

; we want to be able to say

; (put (accumulate + c2 c7) c10)

; In general, the two cell names should be taken as corners of a rectangle, all of whose cells should be included, so these two commands are equivalent:

; (put (accumulate * a3 c5) d7)
; (put (* a3 b3 c3 a4 b4 c4 a5 b5 c5) d7)

; Modify pin-down to convert the accumulate form into the corresponding spelled-out form.

; solution: spread-ex25.scm

(define (pin-down-accu-formula formula id)
  (if (and (= (length formula) 3)
           (cell-name? (cadr formula))
           (cell-name? (caddr formula)))
      (pin-down (spell-accu-cells (car formula)
                                  (first (cadr formula))
                                  (last (cadr formula))
                                  (first (caddr formula))
                                  (last (caddr formula)))
                id)
      (begin (newline)
             (display "illegal accumulate formula: ")
             (display formula)
             (newline))))

(define (spell-accu-cells fun start-col start-row end-col end-row)
  (let ((start-col-index (- (letter->number start-col) 1))
        (end-col-index (- (letter->number end-col) 1)))
    (cons fun (sac-helper start-col-index
                  start-col-index start-row
                  end-col-index end-row))))

(define (sac-helper col
                    start-col-index row
                    end-col-index end-row)
  (cond ((> row end-row) '())
        ((> col end-col-index)
         (sac-helper start-col-index
                     start-col-index (+ row 1)
                     end-col-index end-row))
        (else (cons (word (vector-ref alphabet col) row)
                    (sac-helper (+ col 1)
                                start-col-index row
                                end-col-index end-row)))))

; **********************************************************

; 25.12 Add variable-width columns to the spreadsheet. There should be a command to set the print width of a column. This may mean that the spreadsheet can display more or fewer than six columns.

; solution: spread-ex25.scm

;; init column width data

(define (init-col-widths data index default-width)
  (if (< index 0)
      data
      (begin (vector-set! data index (vector (+ 1 index) default-width))
             (init-col-widths data (- index 1) default-width))))

;; define column width global variable

(define *column-widths*
  (init-col-widths (make-vector *total-cols*) (- *total-cols* 1) 9))

;; column width selector

(define (col-width col)
  (vector-ref (vector-ref *column-widths* (- col 1)) 1))

;; column width mutator

(define (set-col-width! col width)
  (vector-set! (vector-ref *column-widths* (- (letter->number col) 1)) 1 width))
