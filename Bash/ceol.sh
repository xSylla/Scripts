#!/bin/bash -i

HISTCONTROL=ignorespace

PS3='Cosa vuoi fare? '
scelta=(
    "Convertire il certificato in pem" 
    "Decodificare/codificare base64" 
    "Creare un csr" 
    "Controllare un certificato" 
    "Controllare uno store" 
    "Estrazione oggetti da uno store" 
    "Creare uno store PKCS12" 
    "Creare uno store JKS" 
    "Gestione certificati per uno store" 
    "Convertitore jks pcks12" 
    "Ricerca risorse"
)

select fav in "${scelta[@]}"; do
    case $fav in
        "Convertire il certificato in pem")
            ls
            echo -n "Inserisci il file da convertire: " && read -e filename
            echo -n "Vuoi convertire da der o da cer? " && read -e qs
            if [[ "$qs" == "cer" || "$qs" == "ce" || "$qs" == "c" || "$qs" == "crt" ]]; then
                openssl x509 -in "$filename" -out "$filename.pem"
            elif [[ "$qs" == "der" || "$qs" == "de" || "$qs" == "d" ]]; then
                openssl x509 -inform der -in "$filename" -out "$filename.pem"
            fi
            break
            ;;

        "Decodificare/codificare base64")
            echo -n "Vuoi codificare o decodificare? " && read -e qs
            ls
            if [[ "$qs" == "dec" || "$qs" == "decodificare" || "$qs" == "d" ]]; then
                echo -n "Inserisci il file da decodificare: " && read -e filename
                cat "$filename" | base64 -d > "dec.$filename"
            elif [[ "$qs" == "codificare" || "$qs" == "c" || "$qs" == "cod" ]]; then
                echo -n "Inserisci il file da codificare: " && read -e filename
                base64 "$filename" > "cod.$filename"
            fi
            break
            ;;

        "Creare un csr")
            TMP=/tmp/congif.twe
            echo -n "Inserisci il common name: " && read -e common_name
            echo -e "[req]\nreq_extensions = req_ext\n[req_ext]\nsubjectAltName = @alt_names\n[alt_names]\nDNS = $common_name" > $TMP
            openssl req -nodes -sha256 -newkey rsa:2048 -keyout "$common_name.key" -out "$common_name.csr" -subj "/C=IT/ST=Italy/L=Rome/O=Poste Italiane S.p.A./OU=Poste Italiane S.p.A./CN=$common_name" -config $TMP
            rm $TMP
            break
            ;;

        "Controllare un certificato")
            echo -n "Vuoi controllare un certificato x509 (s/n)? " && read -e qs
            ls
            echo -n "Inserisci il file da verificare: " && read -e filename
            if [[ "$qs" == "s" || "$qs" == "si" || "$qs" == "y" || "$qs" == "yes" ]]; then
                openssl x509 -in "$filename" -text -noout
            else
                openssl req -in "$filename" -noout -text
            fi
            break
            ;;

        "Controllare uno store")
            ls
            echo -n "Inserisci lo store da controllare: " && read -e store
            echo -n "Inserisci la password del store: " && read -e password
            echo -n "Vuoi controllarlo in modalitá verbose? " && read -e qs
            if [[ "$qs" == "yes" || "$qs" == "y" || "$qs" == "s" || "$qs" == "si" ]]; then
                keytool -list -v -keystore "$store" -storepass "$password" > "$store.txt"
                cat "$store.txt"
            else
                keytool -list -keystore "$store" -storepass "$password"
            fi
            break
            ;;

        "Estrazione oggetti da uno store")
            ls
            echo -n "Inserisci lo store: " && read -e store
            echo -n "Vuoi estrarre un certificato o una chiave? " && read -e qs
            if [[ "$qs" == "certificato" || "$qs" == "cert" || "$qs" == "cer" || "$qs" == "c" ]]; then
                echo -n "Inserisci la password del store: " && read -e password
                keytool -list -keystore "$store" -storepass "$password"
                echo -n "Inserisci l'alias interessato: " && read -e alias_name
                keytool -export -alias "$alias_name" -keystore "$store" -rfc -file "$alias_name.cert" -storepass "$password"
            elif [[ "$qs" == "chiave" || "$qs" == "key" || "$qs" == "k" ]]; then
                openssl pkcs12 -in "$store" -out keys.pem -nodes -nocerts
            fi
            break
            ;;

        "Creare uno store PKCS12")
            ls
            echo -n "Inserisci il nome dello store (es. store.p12): " && read -e store
            if [ -f "$store" ]; then
                echo "Errore: è giá presente uno store chiamato $store"
            else
                echo -n "Inserisci il certificato (in formato pem): " && read -e mix1
                echo -n "Inserisci la chiave privata: " && read -e mix2
                echo -n "Inserisci l'alias: " && read -e alias_name
                openssl pkcs12 -export -in "$mix1" -inkey "$mix2" -out "$store" -name "$alias_name"
            fi
            break
            ;;

        "Creare uno store JKS")
            ls
            echo -n "Inserisci il nome dello store: " && read -e store
            if [ -f "$store" ]; then
                echo "Errore: è giá presente uno store chiamato $store"
            else
                echo -n "Inserisci l'alias da inserire: " && read -e alias_name
                echo -n "Inserisci il certificato da inserire: " && read -e cert
                echo -n "Inserisci la password: " && read -e password
                keytool -import -alias "$alias_name" -file "$cert" -keystore "$store" -storepass "$password"
            fi
            break
            ;;

        "Gestione certificati per uno store")
            ls
            echo -n "Inserisci lo store: " && read -e store
            echo -n "Inserisci la password del store: " && read -e password
            keytool -list -keystore "$store" -storepass "$password"
            echo -n "Vuoi aggiungere o rimuovere un certificato? " && read -e qs
            if [[ "$qs" == "aggiungere" || "$qs" == "agg" || "$qs" == "a" || "$qs" == "add" ]]; then
                echo -n "Inserisci l'alias da aggiungere: " && read -e alias_name
                echo -n "Inserisci il certificato da aggiungere: " && read -e certificato
                keytool -import -alias "$alias_name" -file "$certificato" -keystore "$store" -storepass "$password"
            elif [[ "$qs" == "rimuovere" || "$qs" == "r" || "$qs" == "rim" || "$qs" == "delete" || "$qs" == "d" ]]; then
                echo -n "Inserisci l'alias da rimuovere: " && read -e alias_name
                keytool -delete -noprompt -alias "$alias_name" -keystore "$store" -storepass "$password"
            fi
            break
            ;;

        "Convertitore jks pcks12")
            ls
            echo -n "Inserisci lo store da convertire: " && read -e store
            echo -n "Che formato é (jks/p12)? " && read -e qs
            if [[ "$qs" == "pkcs12" || "$qs" == "p12" ]]; then
                keytool -importkeystore -srckeystore "$store" -srcstoretype PKCS12 -destkeystore "$store.jks" -deststoretype JKS
            elif [[ "$qs" == "jks" ]]; then
                keytool -importkeystore -srckeystore "$store" -srcstoretype JKS -destkeystore "$store.p12" -deststoretype PKCS12
            fi
            break
            ;;

        "Ricerca risorse")
            tmp_file=/tmp/search.tmp
            echo -n "Inserisci la risorsa da cercare (stringa): " && read risorsa
            echo -n "Vuoi cercare in un progetto specifico? (s/n): " && read -e qs
            if [[ "$qs" == "si" || "$qs" == "s" || "$qs" == "y" ]]; then
                echo -n "Inserisci il nome del progetto: " && read proj_name
                oc get all -n "$proj_name" -o=custom-columns=KIND:.kind,NAME:.metadata.name,NAMESPACE:.metadata.namespace | grep -i "$risorsa" > "$tmp_file"
                oc get secrets -n "$proj_name" -o=custom-columns=KIND:.kind,NAME:.metadata.name,NAMESPACE:.metadata.namespace | grep -i "$risorsa" >> "$tmp_file"
            else
                oc get all -A -o=custom-columns=KIND:.kind,NAME:.metadata.name,NAMESPACE:.metadata.namespace | grep -i "$risorsa" > "$tmp_file"
                oc get secrets -A -o=custom-columns=KIND:.kind,NAME:.metadata.name,NAMESPACE:.metadata.namespace | grep -i "$risorsa" >> "$tmp_file"
            fi
            
            if [ -s "$tmp_file" ]; then
                echo "Risorse trovate:"
                cat "$tmp_file"
            else
                echo "Nessuna risorsa trovata per: $risorsa"
            fi
            rm -f "$tmp_file"
            break
            ;;

        *)
            echo "Opzione non valida."
            ;;
    esac
done