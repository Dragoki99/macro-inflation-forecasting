import os
import matplotlib.pyplot as plt
import pandas as pd
from statsmodels.tsa.ar_model import AutoReg

# 1. Caricamento del dataset salvato in precedenza
data_path = os.path.join("data", "macro_data_raw.csv")
df = pd.read_csv(data_path, index_col=0, parse_dates=True)

# 2. Calcolo dell'inflazione YoY (%)
df["inflation_yoy"] = df["cpi"].pct_change(periods=12) * 100

# 3. Pulizia e allineamento perfetto delle date
# Selezioniamo dal 2000 in poi e rimuoviamo i mesi iniziali vuoti
target = df["inflation_yoy"].loc["2000-01-01":].dropna()

# TRUCCO: rigeneriamo un indice mensile (MS = Month Start) perfetto 
# per assicurarci che statsmodels riesca a calcolare le date future
target.index = pd.date_range(start=target.index[0], periods=len(target), freq="MS")

# 4. Modello Autoregressivo AR(4)
p_lags = 4
model = AutoReg(target, lags=p_lags)
model_fitted = model.fit()

print("\n--- Riepilogo Statistico del Modello AR(4) ---")
# Stampiamo solo i parametri principali per pulizia
print(model_fitted.params)

# 5. Previsione a 6 mesi fuori campione
horizon = 6
forecast = model_fitted.forecast(steps=horizon)

print(f"\n--- Previsioni Inflazione YoY per i prossimi {horizon} mesi ---")
for date, val in forecast.items():
    print(f"{date.strftime('%Y-%m')}: {val:.2f}%")

# 6. Generazione e salvataggio del grafico
plt.figure(figsize=(11, 5))
plt.plot(target.loc["2021":], label="Inflazione Storica YoY (%)", color="#1f77b4", linewidth=2)
plt.plot(forecast, label=f"Forecast AR({p_lags}) (6 mesi)", color="#d62728", linestyle="--", marker="o")
plt.axhline(2.0, color="gray", linestyle=":", label="Target Fed (2.0%)")

plt.title("US CPI Inflation (YoY) - Serie Recente e Previsione AR", fontsize=13)
plt.xlabel("Data")
plt.ylabel("% Variazione Annuale")
plt.legend()
plt.grid(True, linestyle=":", alpha=0.6)
plt.tight_layout()

# Salvataggio dell'immagine per GitHub
os.makedirs("data", exist_ok=True)
plot_output = os.path.join("data", "inflation_forecast.png")
plt.savefig(plot_output, dpi=300)
print(f"\nGrafico salvato in: {plot_output}")

plt.show()