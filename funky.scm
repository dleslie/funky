(module funky *
  (import chicken scheme)
  (use data-structures srfi-1 srfi-13)
  
  ;; This is to demonstrate an attempt to create a new top level binding with syntax
  (define-syntax define-funky
    (syntax-rules ()
      ((_ funk str)
       (define funk (apply circular-list (string-tokenize str))))))

  ;; This is to demonstrate an attempt to inject new bindings with syntax, but only at the syntax scope
  (define-syntax with-funky
    (syntax-rules ()
      ((with-funky funk . body)
       ((lambda ()
	  (let ((the-funk funk))
	    (define (splat) (display (string-concatenate (flatten (zip funk (circular-list " "))))) (newline))
	    (define-syntax expand-body
	      (syntax-rules ()
		((_ lst el)
		 (begin
		   (display (car lst)) (newline)
		   el))
		((_ lst el ..)
		 (begin
		   (display (car lst)) (newline)
		   el
		   (expand-body (cdr lst) ..)))))
	    . body))))))

  ;; This is to demonstrate binding methods from constructed names
  (define-syntax define-funky-method
    (er-macro-transformer
     (lambda (expression inject compare)
       (let ((funky (cadr expression))
	     (name (caddr expression))
	     (body (cdddr expression)))
	 `(lambda (_)
	    (define ,(inject (symbol-append funky '- name))
	      (with-funky ,funky ,@body)))))))

  (define-funky booyah "Get up offa that thing And dance till you feel better Get up offa that thing Try to release the pressure")

  (define-funky-method booyah library-method
    (with-funky booyah
     (display "No\n")
     (display "Not now\n")
     (display "I'm tired\n")
     (display "Just let me sleep\n"))))
