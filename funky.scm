(module funky *
  (import chicken scheme)
  (use data-structures srfi-1 srfi-13)
  
  ;; This is to demonstrate an attempt to create a new top level binding with syntax
  (define-syntax define-funky
    (syntax-rules ()
      ((_ funk str)
       (define funk (apply circular-list (string-tokenize str))))))

  ;; This handy macro allows the rebinding of symbols within a quoted context, and only that context
  ;; From http://community.schemewiki.org/?scheme-faq-macros
  (define-syntax let-alias 
    (syntax-rules () 
      ((_ ((id alias) ...) body ...) 
       (let-syntax ((helper (syntax-rules () 
			      ((_ id ...) (begin body ...))))) 
	 (helper alias ...))))) 
  
  ;; This is to demonstrate an attempt to inject new bindings with syntax, but only at the syntax scope
  (define-syntax with-funky
    (syntax-rules ()
      ((with-funky the-funk . body)
       ;; The immediately-evaluated lambda keeps chicken from segfaulting; replace it with a begin and csc crashes
       ((lambda ()
	  ;; This demonstrates injecting a symbol for the body to access
	  (define (local-splat)
	    (display (string-concatenate (flatten (take the-funk 11) (take (circular-list " ") 11))))
	    (newline))
	  
	   ;; This demonstrates manipulating a form with sub-syntax
	  (define-syntax expand-body
	    (syntax-rules ()
	      ((_ lst) (begin))
	      ((_ lst a . b)
	       (let-alias
		((splat local-splat))
		 (display (car lst)) (newline)
		 a
		 (expand-body (cdr lst) . b)))))
	  (expand-body the-funk . body))))))

  ;; This is to demonstrate binding methods from constructed names
  ;; This is -not- a R5RS standard form
  (define-syntax define-funky-method
    (er-macro-transformer
     (lambda (expression inject compare)
       (let ((funky (cadr expression))
	     (name (caddr expression))
	     (body (cdddr expression)))
	 `(define ,(inject (symbol-append funky '- name))
	    (lambda args (with-funky ,funky ,@body)))))))

  (define-funky booyah "Get up offa that thing And dance till you feel better Get up offa that thing Try to release the pressure")

  (define-funky-method booyah library-method
    (with-funky booyah
     (display "No\n")
     (display "Not now\n")
     (display "I'm tired\n")
     (display "Just let me sleep\n"))))
