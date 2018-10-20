# Systemy-operacyjne

Skrypt do archiwizowania kopii zapasowej wybranych plików

Menu:

 1. Kopia pełna.
 2. Kopia przyrostowa.
 3. Rozpakuj wersję zapisaną.

Kopia zapasowa jest tworzona jako archiwum (plik skompresowany)

Można podać ścieżkę gdzie dana kopia ma być zapisana.

Można wybrać jakie pliki mają być skopiowane lub pomijane przy kopiowaniu (wskazane rozszerzenia)

Gdy chcemy zrobić kolejną kopię danych plików (ich kopia już istnieje) można wybrać czy zrobić kopię przyrostową (aktualizacja istniejącej kopii) czy kopię pełną.

W przypadku wybrania opcji 1 trzeba podać ścieżki do plików, które mają być zawarte w kopii zapasowej. Następnie trzeba określić czy zapisać wszystkie pliki czy tylko wybrane typy.
Jeżeli użytkownik jest zainteresowany tylko niektórymi plikami musi w następnym kroku zaznaczyć, o które pliki chodzi (lub ewentualnie, które pliki są zbędne).
Kolejnym etapem jest podanie ścieżki gdzie kopia ma być zapisana.
Na końcu tworzona jest kopia zapasowa.

W przypadku wybrania opcji 2 jeżeli dana kopia już istnieje, to zostaje ona zmodyfikowana przez dodanie nowych plików. W przeciwnym wypadku użytkownik jest przekierowany do opcji 1.

Po wybraniu opcji 3 użytkownik może zobaczyć listę dostępnych kopii.
Po wyborze jednej z nich zostanie ona rozpakowana.
(W przypadku gdy w danym katalogu istnieją pliki o tych samych nazwach, użytkownik zostaje zapytany czy je nadpisywać).
