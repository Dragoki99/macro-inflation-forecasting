import os
import pandas as pd
from dotenv import load_dotenv
from fredapi import Fred

# 1. Carica la chiave API dal file .env
load_dotenv()
api_key = os.getenv("FRED_API_KEY")

if not api_key:
    raise ValueError("Chiave FRED_API_KEY non trovata nel file .env!")

# 2. Connessione a FRED
fred = Fred(api_key=api_key)

print("Scaricamento dei dati macroeconomici da FRED in corso...")

# 3. Scarichiamo le serie:
# - CPIAUCSL: Consumer Price Index (Tutti i consumatori urbani, SA)
# - UNRATE: Tasso di disoccupazione USA
cpi = fred.get_series("CPIAUCSL")
unrate = fred.get_series("UNRATE")

# 4. Organizziamo i dati in una tabella pulita
df = pd.DataFrame({
    "cpi": cpi,
    "unemployment_rate": unrate
})

# Impostiamo l'indice temporale come mensile
df.index = pd.to_datetime(df.index)
df = df.asfreq("MS")

# 5. Salvataggio su file CSV dentro la cartella data/
output_path = os.path.join("data", "macro_data_raw.csv")
df.to_csv(output_path)

print(f"Dati salvati con successo in: {output_path}")
print(f"Intervallo temporale: da {df.index.min().strftime('%Y-%m')} a {df.index.max().strftime('%Y-%m')}")
print(df.tail())