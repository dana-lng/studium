-- Meilenstein 2
-- 2.4
CREATE TABLE artikel (
	aid INT PRIMARY KEY,
	bezeichnung VARCHAR(30),
	bestand INT CHECK (bestand >= 0),
	preis DECIMAL(10,2) CHECK (preis >= 0),
)

INSERT INTO artikel VALUES(111, 'Stuhl', 1200, 23.60)
INSERT INTO artikel VALUES(112, 'Sofa', 100, 223.60)
INSERT INTO artikel VALUES(113, 'Sessel', 66, 123.60)
INSERT INTO artikel VALUES(115, 'Tisch', 20, 20.00)
INSERT INTO artikel VALUES(117, 'Regal', 12, 3.99)

SELECT * FROM artikel

-- a)
-- Transaktion starten
BEGIN TRANSACTION;

UPDATE artikel
SET bezeichnung = 'Couch'
WHERE bezeichnung = 'Sofa'

SELECT * FROM artikel WHERE aid = '112'

-- Änderung zurücksetzen 
ROLLBACK TRANSACTION

SELECT * FROM artikel WHERE aid = '112'

-- b)
BEGIN TRANSACTION

UPDATE artikel
SET bezeichnung = 'Couch'
WHERE bezeichnung = 'Sofa'

SELECT * FROM artikel WHERE aid = '112'
-- Transaktion wird abgeschlossen, bestätigt und gespeichtert
COMMIT TRANSACTION
SELECT * FROM artikel WHERE aid = '112'

-- c)
BEGIN TRANSACTION

DECLARE @menge_tisch int 
DECLARE @menge_sessel int

SET @menge_sessel = 25
SET @menge_tisch = 10

UPDATE artikel
SET bestand = bestand - @menge_sessel
WHERE bezeichnung = 'Sessel'

UPDATE artikel
SET bestand = bestand - @menge_tisch
WHERE bezeichnung = 'Tisch'

SELECT * FROM artikel

COMMIT TRANSACTION

SELECT * FROM artikel

-- wenn der Code nochmal ausgeführt wird, dann verringert sich die Menge weiter!! -> aber ja, es wurde aktualisiert
-- bzw. wenn man die Werte der Variablen umdrehe, dann klappts nicht, weil der Bestand von Tisch kleiner als 0 wird und das wird mit CHECK abgefangen

-- d)
-- die gesamte Transaktion wird automatisch zurückgesetzt, sobald irgendein Fehler auftritt.
SET XACT_ABORT ON;

BEGIN TRANSACTION

DECLARE @menge_tisch int 
DECLARE @menge_sessel int

SELECT @menge_sessel = 10
SELECT @menge_tisch = 25

UPDATE artikel
SET bestand = bestand - @menge_sessel
WHERE bezeichnung = 'Sessel'

UPDATE artikel
SET bestand = bestand - @menge_tisch
WHERE bezeichnung = 'Tisch'

SELECT * FROM artikel

COMMIT TRANSACTION

SELECT * FROM artikel

-- f)
BEGIN TRANSACTION

DECLARE @gesamt_bestand int
DECLARE @anzahl_stuehle int 
SET @anzahl_stuehle = 1000

UPDATE artikel
SET bestand = bestand + @anzahl_stuehle
WHERE bezeichnung = 'Stuhl'

SELECT @gesamt_bestand = SUM(bestand)
FROM artikel

PRINT @gesamt_bestand 

IF @gesamt_bestand > 2000
	BEGIN
		PRINT 'Bestand zu voll!';
		ROLLBACK TRANSACTION
END 
ELSE IF @gesamt_bestand <= 2000
	BEGIN
		PRINT 'Stühle wurden dem Bestand hinzugefügt'
		COMMIT TRANSACTION
END

SELECT * FROM artikel


-- 2.5
-- UNCOMMITTED: liest auch unbestätigte Änderungen anderer Transaktionen
-- COMMITTED: liest nur bestätigte Daten (Standard)

-- a) Änderungen wurden übernommen -> kein Deadlock 
-- b) Änderungen wurden nicht übernommen -> Deadlock
-- c) Transaktion 1 wurde unterbrochen/zurückgesetzt/gesperrt -> wurde als Deadlock Opfer ausgewählt, 
-- weil T2 gerade B gelesen hat (zweimal, daher solange), T1 aber in B schreiben wollte aber B durch T2 gesperrt wurde
-- d) LOW = Wird als Erstes beendet, wenn ein Deadlock auftritt
--	  NORMAL = Normales Verhalten	
--    HIGH = Wird möglichst nicht beendet
--
--

-- Transaktion 1

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET DEADLOCK_PRIORITY HIGH

BEGIN TRANSACTION
-- r1(A)
SELECT aid,preis FROM Artikel
WHERE aid=111
waitfor delay '00:00:10'
--w1(B)
UPDATE Artikel set bestand=200
WHERE aid = 113
COMMIT


-- 2. Transaktion
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRANSACTION;

-- r2(B)
SELECT aid, bestand 
FROM artikel
WHERE aid = 113;
WAITFOR DELAY '00:00:10';  -- Pause einbauen
-- w2(A)
UPDATE artikel
SET preis = 450
WHERE aid = 111;

COMMIT TRANSACTION;