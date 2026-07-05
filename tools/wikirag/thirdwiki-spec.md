## Was ist thirdwiki
- thirdwiki ist eine Weiterentwicklung von llm-wiki. (siehe llm-wiki.md)
- Es soll als erweiterte Wissensbasis für jegliche LLMs dienen.
- aus der Wissensbasis sollen Tutorials entwickelt werden

## wikis
- jedes wiki ist eigenständig und kann dadurch in den Context geladen werden oder eben auch nicht. (außer `_shared/` Resolution)
- Im setup folder hat jedes wiki (bzw SubWiki) seinen eigenen: 
	- `index.md` 
	- `search_config.md`
	- `quellen.md`
	- `summary.md` *mit Links zu mehr davon*
	- `scopes.md` 
	- `tags.md` 
	- `conventations.md`
	- `log.md` *für Audit-Trail*
	- `stats.md` *hier steht drin wieviele Wörter, Zeichen, Tokens, etc ... das wissen beinhaltet. Gesamt & nach Quellen sortiert*
- Eigenes `CLAUDE.md` in der steht, wo sich alles befindet
- Kann eigenständig geklont/geladen werden (Agent, Offline-Model)

## Ordner Struktur

### thirdwiki
Dies ist der Main Workspace Ordner. Außer der `CLAUDE.md`, liegt hier noch dieses Datei `thirdwiki.md`und die Datei für das was gebaut werden soll, die `llm-wiki.md`.  Zusätzlich kommen noch eine `todoU.md`für dich, eine `todoME.md` für mich und eine `todoWE.md` für uns in der wir weitere Schritte speichern können die grade nicht erledigt werden können. Hinzu kommt noch eine `weiteres.md` in der wahrscheinlich nur ich drin arbeiten werde.
Dazu kommen noch folgende Ordner:
#### plan
Hier kommen die Pläne rein die wir gemeinsam erstellen
#### masterSetupFolder
Da jedes wiki seine eigenen `index.md` , `search_config.md`, `quellen.md`, `summary.md`, `scopes.md` , `tags.md` , `conventations.md`, `log.md` & `stats.md` hat, gibt es hier die jeweiligen master dazu.
#### theWikis
- coding
	- swift
		- Architecture
		- Animations
		- Concurrency
		- Combine
		- Debug & Reverse Engineer
		- HealthKit & Fitness
		- macOS
		- SwiftData
		- SwiftUi
		- Shaders & Metal
		- Embedded Swift
		- Vapor
		- visionOS
		- watchOS
		- old Frameworks (UiKit, CoreData, ...)
		- *... weitere möglich ... abhängig vom input ...*
	- other
		- Kotlin
		- Linux Server
- food & health
	- Rezepte
	- Ernährung
	- Kochen
	- Backen
	- Saisonal Regional
	- Nutritions
	- Warenkunde
	- HeilungsDrinks
	- Heilkräuter
	- Die verschiedenen Ernährungsweisen