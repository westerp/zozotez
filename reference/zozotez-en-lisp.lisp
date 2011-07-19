;;; Zozotez - An imperative lisp interpreter written in CLISP
;;; This is a proof of concept and  hopefully how the BF-version will
;;; behave when given adequate cell size and memory.
;;; run: clisp -modern -repl zozotez-en.lisp

;;; regsym is to register global symbols in both zozotez and clisp at the same time
;;; it is used to simulate a fixed address eg. (eq *cond* expr) will only match when it poits
;;; to the same address. In BF we will look at the address and all the internal functions will reside in the
;;; very beginning of the address space ( NIL, T, ERROR, internal-functions, uder data)

(defun regsym (x type)
    (cond ((atom x) (setf (gethash x *symbols*) (set (intern (concatenate 'string "*" (write-to-string x) "*")) (list type x))))
          (t (cons (regsym (car x) type) (regsym (cdr x) type)))))

(defun zeval ()
  (loop
  (let
      ((expr (pop *stack*))
       (tmp (list *apply*)))
      (cond ( *stack*
        (cond ((symbolp expr)
                   (setf (car (pop *stack*))
                         (multiple-value-bind (value present)
                                   (gethash expr *symbols*)
                                   (cond
                                      ( present value)
                                     ; ( (eq expr '*stack*) (print (zstack)) NIL )
                                      ('T   (setf (cdr *error*) `(Symbol ,expr has no value)) *error*)))))
              ((numberp expr) (setf (car (pop *stack*)) expr ))
              ((listp expr)
                (cond
                      ((or (eq (car expr) 'lambda ) (eq (car expr) 'macro )) (setf (car (pop *stack*)) expr)) ; evaluate LIST-lambda
                      ((eq 'quote (car expr)) (setf (car (pop *stack*)) (cadr expr))) ; quote cannot be handled normally
                      ((eq 'cond (car expr))                                          ; neither can cond.
                        (push tmp *stack*)
                        (setf (cdr tmp)
                          (cons *cond* (car (push (cons '*COND_ARG1* (cons (cdadr expr) (cddr expr))) *stack*))))
                        (push (caadr expr) *stack*) )
                      ((eq *apply* (car expr)) (zapply (cadr expr) (cddr expr)))
                      (t
                        (push tmp *stack*)
                        (setf (cdr tmp) (create-eval-list expr (car expr)))
                      )))
              (t (setf (cdr *error*) `(Symbol ,expr has no value)) (setf (car ret) *error*)))
              (cond ((not(gethash '*loop* *symbols*)) (return (zstack)))))
              (t (return "Au revoir!"))))))
;(trace zeval)

(defun create-eval-list (expr fun &optional (cnt 0) )
    (let ((sym (intern (string-concat "*" (if (listp fun) "LEXPR" (string fun)) "_ARG" (write-to-string cnt) "*"))))
    (cond ((cdr expr)
            ( (lambda (list) (push (cons sym list) *stack*)(push (car expr) *stack*)(cadr *stack*))
                (create-eval-list (cdr expr) fun (+ cnt 1))))
          (t (push (cons sym nil) *stack*)(push (car expr) *stack*)(cadr *stack*)))))

(defun create-progn (ret expr &optional (cnt 0))
    (let ((sym (intern (string-concat "*PROGN" (write-to-string cnt) "*"))))
      (cond ((cdr expr) (create-progn ret (cdr expr) (+ cnt 1))(push (list sym) *stack*)(push (car expr) *stack*))
            (t (push ret *stack*)(push (car expr) *stack*)))))

(defun zapply (fun args &optional (unbind t) )
  (cond
        ((and (listp fun) (eq 'lambda (car fun)))
            (let ((ret (pop *stack*)))
              (if unbind (zbind (cadr fun) args) (zbind-tail (cadr fun) args))
              (cond (unbind
                (push '(*NIL*) *stack*)                                 ; so zstack will print it OK
                (push (cons *apply*(cons  *unbind* (cadr fun))) *stack*)))
              (create-progn ret (cddr fun))))
        ((eq fun *tail-call*) (zapply (car args) (cdr args) nil))
        ((eq fun *unbind*) (pop *stack*)(zunbind args))
        ((eq fun *print*) (setf (car (pop *stack*)) (zprint (car args) (or (eq (car args) *error*) (cdr args)))))
        ((find *error* args) (setf (car (pop *stack*)) *error* ))
        ((eq fun *atom* ) (setf (car (pop *stack*)) (atom (car args))))
        ((eq fun *eq*   ) (setf (car (pop *stack*)) (if (and (numberp (car args)) (numberp (cadr args))) (= (car args) (cadr args)) (eq (car args) (cadr args)) )))
        ((eq fun *cons* ) (setf (car (pop *stack*)) (cons (car args) (cadr args))))
        ((eq fun *car*  ) (setf (car (pop *stack*)) (caar args)))
        ((eq fun *cdr*  ) (setf (car (pop *stack*)) (cdar args)))
        ((eq fun *set*  ) (setf (car (pop *stack*)) (setf (gethash (car args) *symbols*) (cadr args))))
        ((eq fun *read* ) (setf (car (pop *stack*)) (zread)))
        ((eq fun *+*    ) (setf (car (pop *stack*)) (+ (car args) (if (numberp (cadr args)) (cadr args) 0))))
        ((eq fun *-*    ) (setf (car (pop *stack*)) (if (numberp (cadr args)) (- (car args) (cadr args)) (- 0 (car args)))))
        ((eq fun *<*    ) (setf (car (pop *stack*)) (< (car args) (if (numberp (cadr args)) (cadr args) 0))))
        ((eq fun *eval*) ; this you thought was hard but really it's just a stack push to do it :)
              (push (car args) *stack*))
        ((eq fun *repl*)
                  ;; These are just for pretty printing
                  (setf (caddr *repl-print*) '*eval-result*)
                  (setf (caddr *repl-eval*)  '*read-result*)
                  (push *reploop* *stack*)
                  (push '(*NIL*) *stack*)
                  (push *repl-print* *stack*)
                  (push (cddr *repl-print*) *stack*)
                  (push *repl-eval* *stack*)
                  (push (cddr *repl-eval*) *stack*)
                  (push *repl-read* *stack*)
                  ;;(push '(*NIL*) *stack*)
                  ;;(push *repl-hello* *stack*)
                  )
        ((eq fun *cond*)
          (cond ((car args)
                       (create-progn (pop *stack*) (cadr args)))
                ((cddr args)
                       (push (cons 'cond (cddr args)) *stack*))
                (t (setf (car (pop *stack*)) nil))))
;         ((and (listp fun) (eq (car fun) *lambda*))
         ((eq fun *error*) (setf (car (pop *stack*)) *error*))
         (t  (setf (cdr *error*) `(function ,fun not defined))(setf (car (pop *stack*)) *error*))))


;; zbind binds the variables in symbols with the values in values
;; if not symbols in list it is IGNORED
;; more values than symbols are IGNORED
;; less values than symbols are set to NIL (stillmasking eventual global)
(defun zbind (symbols values)
  (cond ((and symbols (atom symbols))
            (multiple-value-bind (value present)
              (gethash symbols *symbols*)
              (cond ( present (push value (gethash symbols *symbols-stack*))))
              (setf (gethash symbols *symbols*) values)))
        ((and (car symbols) (symbolp (car symbols)))
            (multiple-value-bind (value present)
              (gethash (car symbols) *symbols*)
              (cond ( present (push value (gethash (car symbols) *symbols-stack*))))
              (setf (gethash (car symbols) *symbols*) (car values)))
              (zbind (cdr symbols) (cdr values)))))

;; a zbind for tail-calls that only overwrites the symbols
;; without pushing them on the stack but nly the ones added
(defun zbind-tail (symbols values)
  (cond ((and values symbols (atom symbols))
              (setf (gethash symbols *symbols*) values))
        ((and values (car symbols) (symbolp (car symbols)))
              (setf (gethash (car symbols) *symbols*) (car values))
              (zbind-tail (cdr symbols) (cdr values)))))



(defun zunbind (symbols)
  (cond ((and symbols (atom symbols))
           (cond ((gethash symbols *symbols-stack*) (setf (gethash symbols *symbols*) (pop  (gethash symbols *symbols-stack*))))
                (t (remhash symbols *symbols*))))
        ((and (car symbols) (symbolp (car symbols)))
          (cond ((gethash (car symbols) *symbols-stack*) (setf (gethash (car symbols) *symbols*) (pop  (gethash (car symbols) *symbols-stack*))))
                (t (remhash (car symbols) *symbols*)))
          (zunbind (cdr symbols)))))


(defun zread ()
  (let ((content "") (nesting 0) (comment nil) (byte 0))
    (loop
        (setq byte (read-char))
        (cond (comment (if (eq byte #\Newline ) (setf comment nil)))
              ((eq byte #\; ) (setf comment t))
              ((eq byte #\( ) (incf nesting)(setf content (string-concat content "(")))
              ((eq byte #\) ) (cond ((not(eq 0 nesting)) (decf nesting)(setf content (string-concat content ")")))))
              ((and (eq byte #\Newline ) (eq nesting 0) (not(equal "" content))) (return))
              ((and (or (eq byte #\Space) (eq byte #\Tab)) (equal "" content)) nil)
              (t (setf content (string-concat content (string byte))))))
    (setq content (read-from-string (string-concat "(" content ")")))
    (if (cdr content) content (car content))))


;; prints (this is a line) => This is a line\n
;; prints ((this is)(two lines)) => this is\ntwo lines
;; prints (this is (expression)) => This is (expression)\n
;; prints ((this is (expression)) => (this is (expression))
;; prints ((this is (expression)(next line) => this is (expression)\nnext line
(defun zprint (what &optional (string nil))
  (labels ((zprint-parts (x)
                        (princ (car x))
                        (cond ((cdr x) (princ " ") (zprint-parts (cdr x))) ('T (princ (string #\Newline)))))
           (zprint-lines (x)
                        (and x (listp x) (zprint-parts (car x)) (zprint-lines (cdr x)))))
    (cond (string
          (cond ((and (listp what) (listp (car what)) (cadr what) (listp (cadr what)))
                     (zprint-lines what))
                 (t (zprint-parts what)))
                 nil)
          (t (print what)))))

(defun zozotez ()
  (setq *result* '(*NIL*))
  (setq *stack* (list '(eval(read)) *result*))
  (setq *symbols* (make-hash-table :TEST #'eq))
  (setq *symbols-stack* (make-hash-table :TEST #'eq))
  (regsym '(- + < atom quote eq car cdr cons cond lambda apply set read eval print repl tail-call unbind) 'function)
  (setf (gethash '*error* *symbols*) (setq *error* '(ERROR)))
  (setf (gethash 't *symbols*) (setq *T* 't))
  (setf (gethash 'nil *symbols*) (setq *NIL* 'nil))
  (setf (gethash '*loop* *symbols*) *loop*)
  (setq *reploop* '(repl))
  (setq *repl-hello* '(print *repl-hello*))
  (setq *repl-read* (list *apply* *read*))
  (setq *repl-eval* (list *apply* *eval* '*read-result*))
  (setq *repl-print* (list *apply* *print* '*eval-result*))
  (setf (gethash '*repl-hello* *symbols*) 'Zozotez-moi~>)
  (zeval))

;; zstack does a pretty print of the stack
(defun zstack (&optional (x *stack*))
  (cond  ((not(cdr x)) 'nil)
         ((atom (car x)) (cons (cons '*SYMBOL* (cons (car x)(cons '=>(cons  (caadr x) nil)))) (zstack (cddr x))))
         ((eq (caar x) 'quote) (cons (cons '*QUOTE* (cons  (cadar x) (cons '=>(cons  (caadr x) nil)))) (zstack (cddr x))))
         ((eq (caar x) *apply*) (cons (cons '*APPLY* (cons  (cdar x) (cons '=>(cons  (caadr x) nil)))) (zstack (cddr x))))
         ('T (cons (cons '*EXPR* (cons (car x) (cons '=> (cons  (caadr x) nil)))) (zstack (cddr x)))) ))


(setq *loop* t)
;;(progn
;;  (zprint '((Zozotez loaded successfully.)(For debugging do (set' *loop* nil) then do (zeval) for each step)(To exit do (set' repl atom))) t)
  (zozotez);;)


