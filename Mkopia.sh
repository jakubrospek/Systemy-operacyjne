#!/bin/bash

# c -> przez konfiguracje przeprowadza nas kreator graficzny
# t -> konfigaracja poprzez dialog tekstowy w terminalu
# h -> wyswietl pomoc
# v -> wersja programu
# p -> przywroc

# Zmienne pomocnicze
ILE_SCIEZEK=0
ILE_POMINAC=0
ILE_DODAC=0
KONIEC=0
roz_do_dodan=0
roz_do_pomin=0

while getopts acthvr OPCJA;
do
{
	case $OPCJA in
			h)									#tryb pomocy
				echo "skrypt sluzy do tworzenia kopii zapasowej"
				echo "mozesz go uruchomic w sześciu różnych trybach:"
				echo "./kopia.sh -a automatycznie tworzy kopie zapasową na podstawie pliku konfiguracyjnego"
				echo "./kopia.sh -c uruchomi go z konfiguratorem krok po kroku"
				echo "./kopia.sh -t uruchomi go w wersji dialogu w terminalu"
				echo "./kopia.sh -r przywraca kopie zapasową (rozpakowanie)"
				echo "./kopia.sh -h wyświetli pomoc"
				echo "./kopia.sh -v wyświetli informacje o programie";;

			r)									#tryb rozpakowania
				while [ true ];
				do
				{
					TEMP=$(head -n 3 konfiguracja | tail -n 1)		#odczytanie lokalizacjii pliku aktualizacyjnego
					DOCELOWA="${TEMP##DOCELOWA LOKALIZACJA KOPII:}"		#gdzie zapisana jest ścieżka do najnowszej kopii
					TEMP=$(head -n 1 $DOCELOWA/aktualizacja | tail -n 1)	#
					OSTATNIA="${TEMP##SCIEZKA DO OSTATNIEJ KOPII:}"		#Pobranie tej ścieżki
		archiwum=`zenity --entry --title="Podaj ścieżkę do archiwum" --text="(Domyślna ścieżka najnowszego archiwum):" --entry-text "$OSTATNIA"`
					menu=$(zenity --list --title "Archiwizator" --text "" --column "Rozpakuj:" "1.Wszystko" "2.Pojedyncze pliki/foldery")

					if [ $? == "1" ];	#po naciśnięciu anuluj skrypt jest zamykany
					then exit
					fi

					if [ "$menu" == "1.Wszystko" ];
					then
					{
						tar -xvf $archiwum
						exit
					}
					elif [ "$menu" == "2.Pojedyncze pliki/foldery" ];
					then
					{
						while [ $KONIEC -eq 0 ];
						do
						{	
							wybor=$(tar tfz $archiwum | zenity --list --title "" --column "" 2> blad.txt)	#zawartość archiwum
							if [ $? == "0" ];								#przekierowana na okno listy
							then					#wybieramy pojedyncze pliki do rozpakowania
							{					#dopóki nie naciśniemy anuluj
								tar xzvf $archiwum $wybor
							}
							else
							rm blad.txt
							exit
							fi
						}
						done
					}
					fi
				}
				done
				exit;;

			v)
				echo "Archiwizator - wersja 1.0"		#informacja o wersjii i autorze
				echo "Autor: Jakub Rospęk";;
			a)					#tryb błyskawicznego wykonania kopii zapasowej na podstawie informacjii z pliku konfiguracyjnego
				TEMP=$(head -n 2 konfiguracja | tail -n 1)
				TYP_KOPII="${TEMP##TYP KOPII ZAPASOWEJ:}"
				TEMP=$(head -n 3 konfiguracja | tail -n 1)
				DOCELOWA="${TEMP##DOCELOWA LOKALIZACJA KOPII:}"
				TEMP=$(head -n 4 konfiguracja | tail -n 1)
				TAB_SCIEZEK="${TEMP##SCIEZKI WYBRANE DO KOPII:}"
				TEMP=$(head -n 5 konfiguracja | tail -n 1)
				DODANE="${TEMP##TYPY WYBRANE DO DODANIA:}"
				TEMP=$(head -n 6 konfiguracja | tail -n 1)
				POMINIETE="${TEMP##TYPY WYBRANE DO POMINIECIA:}"
				TEMP=$(head -n 7 konfiguracja | tail -n 1)
				roz_do_dodan="${TEMP##ROZSZERZENIA DO DODANIA:}"
				TEMP=$(head -n 8 konfiguracja | tail -n 1)
				roz_do_pomin="${TEMP##ROZSZERZENIA DO POMINIECIA:}";;

			c)								#tryb graficzny
				while [ true ];
				do
				{
					
					TYP_KOPII=$(zenity --list --title "Archiwizator" --text "" --column "MENU:" 						"1.Kopia_pelna" "2.Kopia_przyrostowa" "3.O_programie")
					
					if [ $? == "1" ];
					then exit
					fi

					
					if [ "$TYP_KOPII" = "2.Kopia_przyrostowa" ];
					then							#jeśli zostanie wybrana kopia przyrostowa
					{							#pobierana zostaje ścieżka ostatniej kopii (jeśli taka istnieje)
						TEMP=$(head -n 3 konfiguracja | tail -n 1)	#która zostanie zaktualizowana o nowe dane
						DOMYSLNA="${TEMP##DOCELOWA LOKALIZACJA KOPII:}"

						DOCELOWA=`zenity --entry --title="adres docelowy" --text="Sugerowany adres kopii bazowej:" --entry-text 						"$DOMYSLNA"`					#pobrana sciezka jest domyślnie wyświetlana w oknie dialogowym
						if [ $? == "0" ];				#adresu docelowego
						then
						{
							echo "KONFIGURACJA KOPII ZAPASOWEJ:" > konfiguracja	#informacje zapisywane są w pliku konfiguracyjnym
							echo "TYP KOPII ZAPASOWEJ: $TYP_KOPII" >> konfiguracja
							echo "DOCELOWA LOKALIZACJA KOPII: $DOCELOWA" >> konfiguracja
						}
						else continue
						fi
					}
					elif [ "$TYP_KOPII" = "1.Kopia_pelna" ];
					then
					{
						DOCELOWA=`zenity --entry --title="adres docelowy" --text="Utworz kopie pod adresem:" --entry-text ""`
						if [ $? == "0" ];
						then
						{
							echo "KONFIGURACJA KOPII ZAPASOWEJ:" > konfiguracja
							echo "TYP KOPII ZAPASOWEJ: $TYP_KOPII" >> konfiguracja
							echo "DOCELOWA LOKALIZACJA KOPII: $DOCELOWA" >> konfiguracja
						}
						else continue
						fi
					}
					elif [ "$TYP_KOPII" = "3.O_programie" ];
					then
					{
						infor=`zenity --info --text="Archiwizator\nwersja: 1.0\nAutor: Jakub Rospęk\n"`
						continue
					}
					fi
					
					while [ $KONIEC -eq 0 ];	# pętla dodająca kolejne ścieżki plików/folderów do tablicy
					do
					{
						SCIEZKI=`zenity --title="sciezki" --list --radiolist --column "" --column "chcesz podac sciezke czy 							plik?"  TRUE sciezke FALSE plik FALSE wystarczy`
						
						if [ "$SCIEZKI" = "sciezke" ];
						then
						{
							SKAD=`zenity --entry --title="" --text="Podaj sciezke do umieszczenia w kopii:" --entry-text ""`
							TAB_SCIEZEK[ILE_SCIEZEK]=$SKAD
							ILE_SCIEZEK+=1
						}
						elif [ "$SCIEZKI" = "plik" ];
						then
						{
							SKAD=`zenity --file-selection --title="wybierz plik"`
							TAB_SCIEZEK[ILE_SCIEZEK]=$SKAD
							ILE_SCIEZEK+=1
						}
						elif [ "$SCIEZKI" = "wystarczy" ];	# warunek kończący działanie pętli
						then
						{
							KONIEC=1
						}
						else
						exit
						fi
					}
					done

					echo "SCIEZKI WYBRANE DO KOPII: ${TAB_SCIEZEK[@]}" >> konfiguracja	#informacje zapisywane są w pliku konfiguracyjnym

					SCIEZKI=`zenity --title="typy" --list --radiolist --column "" --column "chcesz wybrac, jakie typy maja sie 						znalesc w kopii i/lub jakie pominac?"  TRUE NIE FALSE TAK`		#wybieranie określonych rozszerzeń plików

					if [ "$SCIEZKI" = "TAK" ];
					then
					{
						KONIEC=0
						while [ $KONIEC = 0 ]				#pętla wyboru dodająca kolejne rozszerzenia do tablicy
						do
						{
							SCIEZKI=`zenity --title="typ" --list --radiolist --column "" --column "chcesz dodac 								rozszezenie do:"  TRUE dodania FALSE pominiecia FALSE "ok, skonczylem"`
							if [ "$SCIEZKI" = "pominiecia" ];	#rozróżnienie na rozszerzenia do pominięcia
							then
							{
								roz_do_pomin=1			# zapisujemy wybór bo będzie potrzebny w warunku pod koniec
								roz_do_dodan=0

								POMINIETE[ILE_POMINAC]=`zenity --entry --title="TYP DO POMINIECIA" --text="Pomin pliki 									o rozszezeniu:" --entry-text ""`
								ILE_POMINAC+=1
								DODANE=""
							}
							elif [ "$SCIEZKI" = "dodania" ];	#...lub na rozszerzenia do dodania
							then
							{
								roz_do_dodan=1			# zapisujemy wybór bo będzie potrzebny w warunku pod koniec
								roz_do_pomin=0

								DODANE[ILE_DODAC]=`zenity --entry --title="TYP DO DODANIA" --text="Dodaj pliki o 									rozszezeniu:" --entry-text ""`
								ILE_DODAC+=1
								POMINIETE=""
							}
							else					#wybór "ok, skonczylem"
							{
								echo "TYPY WYBRANE DO DODANIA: ${DODANE[@]}" >> konfiguracja	#informacje zapisywane są w pliku
								echo "TYPY WYBRANE DO POMINIECIA: ${POMINIETE[@]}" >> konfiguracja	#konfiguracyjnym
								echo "ROZSZERZENIA DO DODANIA: $roz_do_dodan" >> konfiguracja
								echo "ROZSZERZENIA DO POMINIECIA: $roz_do_pomin" >> konfiguracja
								KONIEC=1							#kończenie pętli wyboru
							}
							fi
						}
						done
					}
					else
					{
						DODANE=""
						POMINIETE=""
						echo "TYPY WYBRANE DO DODANIA: ${DODANE[@]}" >> konfiguracja			#informacje zapisywane są w pliku
						echo "TYPY WYBRANE DO POMINIECIA: ${POMINIETE[@]}" >> konfiguracja		#konfiguracyjnym
						echo "ROZSZERZENIA DO DODANIA: $roz_do_dodan" >> konfiguracja
						echo "ROZSZERZENIA DO POMINIECIA: $roz_do_pomin" >> konfiguracja
					}	
					fi
											#Podsumowanie całości wyborów
					zenity --text-info \--title="Podsumowanie:" \--filename=`dirname $0`/konfiguracja \--checkbox="ZGADZA SIE! DZIALAJ!"
					break
					
				}
				done;;
			
			t)									#tryb tekstowy terminala (ten sam mechanizm co w trybie graficznym)
				echo "podaj typ kopii: pelna (p) lub przyrostowa (r)"
				read TYP_KOPII
				if [ "$TYP_KOPII" = "r" ];
				then
				{
					TYP_KOPII=2.Kopia_przyrostowa;
					TEMP=$(head -n 3 konfiguracja | tail -n 1)
					DOMYSLNA="${TEMP##DOCELOWA LOKALIZACJA KOPII:}"
					echo "sugerowana sciezka docelowa, gdzie znajduje się kopia bazowa:"
					echo "$DOMYSLNA"
					DOCELOWA="$DOMYSLNA"
					echo "KONFIGURACJA KOPII ZAPASOWEJ:" > konfiguracja
					echo "TYP KOPII ZAPASOWEJ: $TYP_KOPII" >> konfiguracja
				}
				else
				{
					TYP_KOPII=1.Kopia_pelna;
					echo "KONFIGURACJA KOPII ZAPASOWEJ:" > konfiguracja
					echo "TYP KOPII ZAPASOWEJ: $TYP_KOPII" >> konfiguracja
					echo "podaj sciezke docelowa, w ktorej bedzie miala powstac kopia zapasowa"
					read DOCELOWA
				}
				fi

				echo "DOCELOWA LOKALIZACJA KOPII: $DOCELOWA" >> konfiguracja
				echo "podaj liste sciezek, ktore beda mialy znalezc sie w kopii"
				echo "kolejne sciezki oddziel spacjami"
				read TAB_SCIEZEK[ILE_SCIEZEK]
				ILE_SCIEZEK+=1
				echo "SCIEZKI WYBRANE DO KOPII: ${TAB_SCIEZEK[@]}" >> konfiguracja
				echo "chcesz dodac do kopii wszystko? t/n"
				read OPCJA
				if [ "$OPCJA" = "n" ];
				then
				{
					echo "chcesz podac rozszezenia, ktore maja byc dodane? (d) czy pominiete? (p)"
					read OPCJA
					if [ $OPCJA = "d" ];
					then
					{
						roz_do_dodan=1
						roz_do_pomin=0
						
						echo "podaj liste rozszezen do dodania rozdzielajac je spacjami"
						read DODANE[ILE_DODAC]
						ILE_DODAC+=1
						POMINIETE=""
						echo "TYPY WYBRANE DO DODANIA: ${DODANE[@]}" >> konfiguracja
						echo "TYPY WYBRANE DO POMINIECIA: ${POMINIETE[@]}" >> konfiguracja
						echo "ROZSZERZENIA DO DODANIA: $roz_do_dodan" >> konfiguracja
						echo "ROZSZERZENIA DO POMINIECIA: $roz_do_pomin" >> konfiguracja
					}
					elif [ "$OPCJA" = "p" ];
					then
					{
						roz_do_pomin=1
						roz_do_dodan=0
						
						echo "podaj liste rozszezen do pominiecia rozdzielajac je spacjami"
						read POMINIETE[ILE_POMINAC]
						ILE_POMINAC+=1
						DODANE=""
						echo "TYPY WYBRANE DO DODANIA: ${DODANE[@]}" >> konfiguracja
						echo "TYPY WYBRANE DO POMINIECIA: ${POMINIETE[@]}" >> konfiguracja
						echo "ROZSZERZENIA DO DODANIA: $roz_do_dodan" >> konfiguracja
						echo "ROZSZERZENIA DO POMINIECIA: $roz_do_pomin" >> konfiguracja
					}
					fi
				}
				else
				{
					echo ""
					echo ""
				}			
				fi;;
			*)						#tryb domyślny=pomoc - wyświetla się jeśli uruchomimy skrypt bez parametru początkowego
				echo "skrypt sluzy do tworzenia kopii zapasowej"
				echo "mozesz go uruchomic w sześciu różnych trybach:"
				echo "./kopia.sh -a automatycznie tworzy kopie zapasową na podstawie pliku konfiguracyjnego"
				echo "./kopia.sh -c uruchomi go z konfiguratorem krok po kroku"
				echo "./kopia.sh -t uruchomi go w wersji dialogu w terminalu"
				echo "./kopia.sh -r przywraca kopie zapasową (rozpakowanie)"
				echo "./kopia.sh -h wyświetli pomoc"
				echo "./kopia.sh -v wyświetli informacje o programie";;

esac
}
done


cd $DOCELOWA		# wchodzimy do katalogu docelowego kopii
mkdir temp		# tworzenie tymczasowego katalogu, do ktorego przenoszone beda pliki, majace znaleźć się w kopii zapasowej

TEMP=$(head -n 1 aktualizacja | tail -n 1)		# pobieramy ścieżkę do ostatniej kopii z pliku aktualizacyjnego
OSTATNIA="${TEMP##SCIEZKA DO OSTATNIEJ KOPII:}"



if [ "$OSTATNIA" = "" ];				# jeśli nie istnieje automatycznie jest wykonywana kopia pełna
then
{
	TYP_KOPII=1.Kopia_pelna
}
fi

if [ "$TYP_KOPII" != "2.Kopia_przyrostowa" ];
then
{
	TYP_KOPII=1.Kopia_pelna
}
fi

if [ $TYP_KOPII = "1.Kopia_pelna" ];			# w przypadku kopii pełnej:
then
{
	
	for sciezka in ${TAB_SCIEZEK[@]};
	do
	cp -RPp $sciezka $DOCELOWA/temp			# kopiowane są zgromadzone ścieżki plików/folderów do folderu temp
	done

for sciezka in ${TAB_SCIEZEK[@]};			# gdy kopiowana ścieżka jest plikiem to zwracany jest błąd i cała pętla for z algorytmem rozszerzeń do
do							# dodania/pominięcia jest ignorowana i skrypt przechodzi do etapu tworzenia archiwum
{
	cd $sciezka					# wchodzimy do danej lokalizacjii (jeśli jest katalogiem)
	cd ../						# cofamy się do katalogu nadrzędnego
	katalogi_nad=`pwd`				# pobieramy ścieżkę do katalogu nadrzędnego
	nazwa_kat="${sciezka##$katalogi_nad/}"		# wyodrębniamy z pełnej ścieżki nazwę katalogu który ma zostać dodany do kopii zapasowej
	
	if [ $roz_do_pomin == 1 ];			# jeżeli na wcześniejszym etapie algorytmu została aktywowana opcja rozszerzeń do pominięcia:
	then
	{
		cd $DOCELOWA/temp/$nazwa_kat		# to wchodzimy do skopiowanego katalogu w folderze temp
		for rozszerzenie in ${POMINIETE[@]};
		do
		{
			`rm *.$rozszerzenie`		# i usuwamy pliki o wytypowanych wcześniej rozszerzeniach
		}
		done
		
	}
	elif [ $roz_do_dodan == 1 ];			# jeżeli aktywowana została opcja rozszerzeń do dodania
	then
	{
		cd $DOCELOWA/temp/$nazwa_kat		# to wchodzimy do skopiowanego katalogu w folderze temp
		mkdir $nazwa_kat			# tworzymy w nim podkatalog o tej samej nazwie
		for rozszerzenie in ${DODANE[@]};
		do
		{
			`mv *.$rozszerzenie $DOCELOWA/temp/$nazwa_kat/$nazwa_kat`	# i przenosimy pliki o wytypowanych rozszerzeniach do tego podkatalogu
		}
		done
		
		mv $DOCELOWA/temp/$nazwa_kat/$nazwa_kat $DOCELOWA			# następnie podkatalog przenosimy 'na zewnątrz' katalogu temp
		rm -r $DOCELOWA/temp/$nazwa_kat						# w katalogu temp usuwamy katalog ze zbędnymi rozszerzeniami
		mv $DOCELOWA/$nazwa_kat $DOCELOWA/temp					# i katalog 'z zewnątrz' spowrotem przenosimy do katalogu temp
	}
	fi
}
done

# tworzenie archiwum

DATA=`date +%F`
GODZ=`date +%H`
MIN=`date +%M`
NAZWA=`echo "$DATA""_""$GODZ""_""$MIN"`							# nazwą archiwum będzie data i czas w momencie jego powstania

	cd $DOCELOWA									# wchodzimy do lokalizacjii z katalogiem temp
	tar -zcvf $NAZWA.tar -C $DOCELOWA temp						# archiwizujemy go

rm -r $DOCELOWA/temp									# po czym usuwamy zbędny już katalog temp z całą zawartością
echo "SCIEZKA DO OSTATNIEJ KOPII: $DOCELOWA/$NAZWA.tar" > aktualizacja			# zapisujemy pełną ścieżkę do najnowszego archiwum w pliku aktualizacjii

}
elif [ $TYP_KOPII = "2.Kopia_przyrostowa" ];						# w przypadku kopii przyrostowej:
then
{
	rm -r $DOCELOWA/temp
	cd $DOCELOWA						# wchodzimy do lokalizacjii docelowej powstającego archiwum
	tar -xvf $OSTATNIA					# wypakowujemy ostatnie archiwum (pojawia się folder temp z plikami/folderami
	rm $OSTATNIA						# usuwamy ostatnie archiwum

	for sciezka in ${TAB_SCIEZEK[@]};
	do
	cp -RPp $sciezka $DOCELOWA/temp				# kopiujemy wybrane pliki/foldery do katalogu temp
	done
#---------------------------------------------------------------------------------------------------------------------------------------------------------

for sciezka in ${TAB_SCIEZEK[@]};				# tutaj jest ten sam mechanizm rozszerzeń do dodania lub pominięcia
do								# co w przypadku Kopii pełnej
{
	cd $sciezka
	cd ../
	katalogi_nad=`pwd`
	nazwa_kat="${sciezka##$katalogi_nad/}"
	
	if [ $roz_do_pomin == 1 ];
	then
	{
		cd $DOCELOWA/temp/$nazwa_kat
		for rozszerzenie in ${POMINIETE[@]};
		do
		{
			`rm *.$rozszerzenie`
		}
		done
		
	}
	elif [ $roz_do_dodan == 1 ];
	then
	{
		cd $DOCELOWA/temp/$nazwa_kat
		mkdir $nazwa_kat
		for rozszerzenie in ${DODANE[@]};
		do
		{
			`mv *.$rozszerzenie $DOCELOWA/temp/$nazwa_kat/$nazwa_kat`
		}
		done
		
		mv $DOCELOWA/temp/$nazwa_kat/$nazwa_kat $DOCELOWA
		rm -r $DOCELOWA/temp/$nazwa_kat
		mv $DOCELOWA/$nazwa_kat $DOCELOWA/temp
	}
	fi
}
done

#---------------------------------------------------------------------------------------------------------------------------------------------------------
# tworzenie archiwum								ten sam mechanizm tworzenia archiwum co w przypadku Kopii pełnej

DATA=`date +%F`
GODZ=`date +%H`
MIN=`date +%M`
NAZWA=`echo "$DATA""_""$GODZ""_""$MIN"`

	cd $DOCELOWA
	tar -zcvf $NAZWA.tar -C $DOCELOWA temp

rm -r $DOCELOWA/temp
echo "SCIEZKA DO OSTATNIEJ KOPII: $DOCELOWA/$NAZWA.tar" > aktualizacja

} 
fi

