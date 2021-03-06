;;;  http://dave-reed.com/csc533.S10/Code/eliza.scm
;;;
;;;  eliza.scm    Dave Reed    4/10/10
;;;
;;;  This program implements the Eliza psychologist as described in
;;;  "Paradigms in Artificial Intelligence Programming" by Norvig.
;;;  The call  (eliza)  starts up the psychologist and produces the
;;;  "Eliza>" prompt.  The user then must type questions/statements to
;;;  which Eliza responds.  As is, the user must type questions/statements
;;;  as lowercase words in a list.  Punctuation should not be included, as 
;;;  this can sometimes impede matching.  To stop eliza, enter (bye).  
;;;

(define (eliza)
  (begin (display 'Eliza>)
         (let ((input (read)))
             (if (equal? input '(bye))
                 (display '(Have a nice day))
                 (begin (display (apply-rule ELIZA-RULES input))
                        (newline)
                        (eliza))))))

(define (apply-rule rules input)
  (let ((result (pattern-match (caar rules) input '())))
    (if (equal? result 'failed) 
        (apply-rule (cdr rules) input)
        (apply-substs (switch-viewpoint result)
  		      (random-ele (cdar rules))))))

(define (apply-substs substs target)
  (cond ((null? target) '())
        ((and (list? (car target)) (not (variable? (car target))))
         (cons (apply-substs substs (car target))
               (apply-substs substs (cdr target))))
        (else (let ((value (assoc (car target) substs)))
                (if (list? value)
	            (append (cddr value) 
                            (apply-substs substs (cdr target)))
	            (cons (car target)
                          (apply-substs substs (cdr target))))))))

(define (switch-viewpoint words)
  (apply-substs '((i <-- you) (you <-- i) (me <-- you) 
                  (you <-- me) (am <-- are) (are <-- am) 
                  (my <-- your) (your <-- my)
                  (yourself <-- myself) (myself <-- yourself)) words))


(define (variable? x)
  (and (list? x) (equal? (car x) 'VAR)))



;;;
;;; This function performs pattern matching, where the pattern (containing
;;; variables represented as (VAR X)) is matched with the input, resulting
;;; in the appropriate substitutions.
;;;

(define (pattern-match pattern input substs)
  (define (match-variable var input substs)
    (let ((subst (assoc var substs)))
      (cond ((equal? subst #f)
             (if (symbol? input)
		 (cons (list var input) substs)
		 (cons (cons var (cons '<-- input)) substs)))
            ((equal? input (cdr subst)) substs)
            (else 'failed))))

  (define (segment-match pattern input substs start)
    (let ((var (car pattern)) (pat (cdr pattern)))
      (if (null? pat)
          (match-variable var input substs)
          (let ((pos (position-from (car pat) input start)))
	    (if (zero? pos)
		'failed
		(let ((b2 (pattern-match 
			           pat
				   (subseq input pos (length input))
				   (match-variable 
				       var 
				       (subseq input 1 (- pos 1))
				       substs))))
                    (if (equal? b2 'failed)
			(segment-match pattern input substs (+ pos 1))
			b2)))))))
  (cond
    ((equal? substs 'failed) 'failed)
    ((equal? pattern input) substs)
    ((and (list? pattern) (not (null? pattern))
          (variable? (car pattern)))
     (segment-match pattern input substs 1))
    ((and (list? pattern) (not (null? pattern))
          (list? input)   (not (null? input)))
     (pattern-match (cdr pattern) (cdr input)
                    (pattern-match (car pattern) (car input) substs)))
    (else 'failed)))



;;;
;;;  Utilities
;;;


(define (random-ele elelist)
  (list-ref elelist (random (length elelist))))

(define (position-from ele elelist start)
  (define (position-from-help count cdrlist)
    (cond ((null? cdrlist) 0)
          ((and (>= count start) (equal? ele (car cdrlist))) count)
          (else (position-from-help (+ 1 count) (cdr cdrlist)))))
    (position-from-help 1 elelist))

(define (subseq elelist i j)
  (define (subseq-help count cdrlist)
    (cond ((or (null? cdrlist) (> count j)) '())
          ((< count i) (subseq-help (+ 1 count) (cdr cdrlist)))
          (else (cons (car cdrlist)
                      (subseq-help (+ 1 count) (cdr cdrlist))))))
  (subseq-help 1 elelist))



;;;
;;;  These are the original rules for the Eliza pyschologist as described in
;;;  "Paradigms in Artificial Intelligence Programming" by Norvig.  
;;;

(define ELIZA-RULES
  '((((VAR X) hello (VAR Y))
     (how do you do.  please state your problem))
    (((VAR X) computer (VAR Y))
     (do computers worry you)
     (what do you think about machines)
     (why do you mention computers)
     (what do you think machines have to do with your problem))
    (((VAR X) name (VAR Y))
     (i am not interested in names))
    (((VAR X) sorry (VAR Y))
     (please don't apologize)
     (apologies are not necessary)
     (what feelings do you have when you apologize))
    (((VAR X) i remember (VAR Y))
     (do you often think of (VAR Y))
     (does thinking of (VAR Y) bring anything else to mind)
     (what else do you remember?)
     (why do you recall (VAR Y) right now)
     (what in this present situation reminds you of (VAR Y))
     (what is the connection between me and (VAR Y)))
    (((VAR X) do you remember (VAR Y))
     (did you think i would forget (VAR Y))
     (why do you think i should recall (VAR Y))
     (what about (VAR Y))
     (you mentioned (VAR Y)))
    (((VAR X) if (VAR Y))
     (do you really think it is likely that (VAR Y))
     (do you wish that (VAR Y))
     (what do you think about (VAR Y))
     (really -- if (VAR Y)))
    (((VAR X) i dreamt (VAR Y))
     (really -- (VAR Y))
     (have you ever fantasized (VAR Y) while you were awake)
     (have you dreamt (VAR Y) before))
    (((VAR X) i dreamed (VAR Y))
     (really -- (VAR Y))
     (have you ever fantasized (VAR Y) while you were awake)
     (have you dreamed (VAR Y) before))
    (((VAR X) dream (VAR Y))
     (what does this dream suggest to you)
     (do you dream often)
     (what persons appear in your dreams)
     (don't you believe that dream has to do with your problem))
    (((VAR X) my mother (VAR Y))
     (who else is in your family (VAR Y))
     (tell me more about your family))
    (((VAR X) my father (VAR Y))
     (your father)
     (does he influence you strongly)
     (what else comes to mind when you think of your father))
    (((VAR X) i want (VAR Y))
     (what would it mean if you got (VAR Y))
     (why do you want (VAR Y))
     (suppose you got (VAR Y) soon))
    (((VAR X) i am glad (VAR Y))
     (how have i helped you to be (VAR Y))
     (what makes you happy just now)
     (can you explain why you are suddenly (VAR Y)))
    (((VAR X) i am happy (VAR Y))
     (how have i helped you to be (VAR Y))
     (what makes you glad just now)
     (can you explain why you are suddenly (VAR Y)))
    (((VAR X) i am sad (VAR Y))
     (i am sorry to hear you are depressed)
     (i'm sure it's not pleasant to be sad))
    (((VAR X) i am unhappy (VAR Y))
     (i am sorry to hear you are depressed)
     (i'm sure it's not pleasant to be unhappy))
    (((VAR X) are like (VAR Y))
     (what resemblence do you see between (VAR X) and (VAR Y)))
    (((VAR X) is like (VAR Y))
     (in what way is it that (VAR X) is like (VAR Y))
     (what resemblence do you see)
     (could there really be some connection)
     (how))
    (((VAR X) alike (VAR Y))
     (in what way)
     (what similarities are there))
    (((VAR X) same (VAR Y))
     (what other connections do you see))
    (((VAR X) i was (VAR Y))
     (were you really)
     (perhaps i already knew you were (VAR Y))
     (why do you tell me you were (VAR Y) now))
    (((VAR X) was i (VAR Y))
     (what if you were (VAR Y))
     (do you think you were (VAR Y))
     (what would it mean if you were (VAR Y)))
    (((VAR X) i am (VAR Y))
     (in what way are you (VAR Y))
     (do you want to be (VAR Y)))
    (((VAR X) am i (VAR Y))
     (do you believe you are (VAR Y))
     (would you want to be (VAR Y))
     (you wish i would tell you you are (VAR Y))
     (what would it mean if you were (VAR Y)))
    (((VAR X) am (VAR Y))
     (why do you say "am")
     (i don't understand that))
    (((VAR X) are you (VAR Y))
     (why are you interested in whether i am (VAR Y) or not)
     (would you prefer it if i weren't (VAR Y))
     (perhaps i am (VAR Y) in your fantasies))
    (((VAR X) you are (VAR Y))
     (what makes you think i am (VAR Y)))
    (((VAR X) because (VAR Y))
     (is that the real reason)
     (what other reason might there be)
     (does that reason seem to explain anything else))
    (((VAR X) were you (VAR Y))
     (perhaps i was (VAR Y))
     (what do you think)
     (what if i had been (VAR Y)))
    (((VAR X) i can't (VAR Y))
     (maybe you could (VAR Y) now)
     (what if you could (VAR Y)))
    (((VAR X) i feel (VAR Y))
     (do you often feel (VAR Y)))
    (((VAR X) i felt (VAR Y))
     (what other feelings do you have))
    (((VAR X) i (VAR Y) you (VAR Z))
     (perhaps in your fantasies we (VAR Y) each other))
    (((VAR X) why don't you (VAR Y))
     (should you (VAR Y) yourself)
     (do you believe i don't (VAR Y))
     (perhaps i will (VAR Y) in good time))
    (((VAR X) yes (VAR Y))
     (you seem quite positive)
     (you are sure)
     (i understand))
    (((VAR X) no (VAR Y))
     (why not)
     (you are being a bit negative)
     (are you saying "no" just to be negative))
    (((VAR X) someone (VAR Y))
     (can you be more specific))
    (((VAR X) everyone (VAR Y))
     (surely not everyone)
     (can you think of anyone in particular)
     (who for example)
     (you are thinking of a special person))
    (((VAR X) always (VAR Y))
     (can you think of a specific example)
     (when)
     (what incident are you thinking of)
     (really -- always))
    (((VAR X) what (VAR Y))
     (why do you ask)
     (does that question interest you)
     (what is it you really want to know)
     (what do you think)
     (what comes to your mind when you ask that))
    (((VAR X) perhaps (VAR Y))
     (you do not seem quite certain))
    (((VAR X) are (VAR Y))
     (do you think they might not be (VAR Y))
     (possibly they are (VAR Y)))
    (((VAR X))
     (very interesting)
     (i am not sure i understand you fully)
     (what does that suggest to you)
     (please continue)
     (go on)
     (do you feel strongly about discussing such things))))

