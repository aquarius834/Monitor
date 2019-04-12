(defmodule MAIN (export ?ALL))
(defmodule INPUT (import MAIN ?ALL))
(defmodule TRENDS (import MAIN ?ALL))
(defmodule WARNINGS (import MAIN ?ALL))

(deftemplate MAIN::device
	(slot name (type SYMBOL))
	(slot status (allowed-values on off))
)

(deftemplate MAIN::sensor
	(slot name (type SYMBOL))
	(slot device (type SYMBOL))
	(slot raw-value (type SYMBOL NUMBER) (allowed-symbols none) (default none))
	(slot state (allowed-values low-red-line low-guard-line normal high-red-line high-guard-line) (default normal))
	(slot low-red-line (type NUMBER))
	(slot low-guard-line (type NUMBER))
	(slot high-guard-line (type NUMBER))
	(slot high-red-line (type NUMBER))
)

(defclass INPUT::DATA-SOURCE
	(is-a USER)
)

(defmessage-handler INPUT::DATA-SOURCE
	get-data (?name)
	(printout t "Input value for sensor " ?name ": ")
	(read)
) 

(defmessage-handler INPUT::DATA-SOURCE
	next-cycle (?cycle)
)

(defclass INPUT::INSTANCE-DATA-SOURCE
	(is-a DATA-SOURCE)
)

(defmessage-handler INPUT::INSTANCE-DATA-SOURCE
	get-data (?name)
	(bind ?sensor-data (instance-name (sym-cat ?name -DATA-SOURCE)))
	(if (not (instance-existp ?sensor-data)) then (return nil))
	(bind ?data (send ?sensor-data get-data))
	(if (= (length$ ?data) 0) then (return nil))
	(send ?sensor-data put-data (rest$ ?data))
	(nth$ 1 ?data)
)

(defclass INPUT::SENSOR-DATA
	(is-a USER)
	(multislot data)
)

(defclass INPUT::FILE-DATA-SOURCE
	(is-a DATA-SOURCE)
	(slot file-logical-name (default FALSE))
	(multislot sensor)
	(multislot value)
)

(defmessage-handler INPUT::FILE-DATA-SOURCE
	get-file ()
	(bind ?logical-name (gensym*))
	(while TRUE
		(printout t "What is the name of the data file? ")
		(bind ?file-name (readline))
		(if (open ?file-name ?logical-name "r")
			then (bind ?self:file-logical-name ?logical-name) (return)
		)
	)
)

(defmessage-handler INPUT::FILE-DATA-SOURCE
	put-sensor-value (?sensor ?value)
	(bind ?position (member$ ?sensor ?self:sensor))
	(if ?position
		then (bind ?self:value (replace$ ?self:value ?position ?position ?value))
		else
			(bind ?self:sensor ?self:sensor ?sensor)
			(bind ?self:value ?self:value ?value)
	)
)

(defmessage-handler INPUT::FILE-DATA-SOURCE
	next-cycle (?cycle)
	(if (not ?self:file-logical-name)
	then (send ?self get-file))
	(bind ?name (read ?self:file-logical-name))
	(if (eq ?name EOF)
		then (send ?self close-data-source) (return)
	)
	(while (and (neq ?name end-of-cycle) (neq ?name EOF))
		(bind ?raw-value (read ?self:file-logical-name))
		(if (eq ?raw-value EOF)
			then (send ?self close-data-source) (return)
		)
		(send ?self put-sensor-value ?name ?raw-value)
		(bind ?name (read ?self:file-logical-name))
		(if (eq ?name EOF)
		then (send ?self close-data-source) (return)
		)
	)
)

(defmessage-handler INPUT::FILE-DATA-SOURCE
	get-data (?name)
	(bind ?position (member$ ?name ?self:sensor))
	(if ?position
		then (nth$ ?position ?self:value)
		else (return nil)
	)
)

(defmessage-handler INPUT::FILE-DATA-SOURCE
	close-data-source ()
	(close ?self:file-logical-name)
	(bind ?self:sensor (create$))
	(bind ?self:value (create$))
)

(deftemplate MAIN::sensor-trend
	(slot name)
	(slot state (default normal))
	(slot start (default 0))
	(slot end (default 0))
	(slot shutdown-duration (default 3))
)

