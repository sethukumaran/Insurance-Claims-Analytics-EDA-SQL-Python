import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

claims = pd.read_csv("claims.csv", parse_dates=["loss_date","reported_on"])
payments = pd.read_csv("claim_payments.csv", parse_dates=["paid_on"])
policies = pd.read_csv("policies.csv", parse_dates=["start_date","end_date"])
holders = pd.read_csv("policyholders.csv", parse_dates=["date_of_birth","licensed_since"])
vehicles = pd.read_csv("vehicles.csv")

# Initial EDA
for name, df in {"claims":claims,"payments":payments,"policies":policies,
                 "holders":holders,"vehicles":vehicles}.items():
    print(name, df.shape)
    print(df.dtypes)
    print("Nulls:", df.isna().sum().to_dict())
    print("Duplicates:", df.duplicated().sum())
    print(df.describe(include="all").transpose().head(20))

# Relational model
pay_agg = payments.groupby("claim_id").agg(
    payment_count=("payment_id","count"),
    payment_sum=("amount","sum"),
    first_payment=("paid_on","min"),
    last_payment=("paid_on","max")
).reset_index()

x = (claims.merge(policies,on="policy_id",how="left",suffixes=("","_policy"))
          .merge(holders,on="policyholder_id",how="left",suffixes=("","_holder"))
          .merge(vehicles,on="vehicle_id",how="left",suffixes=("","_vehicle"))
          .merge(pay_agg,on="claim_id",how="left"))

x["payment_count"]=x["payment_count"].fillna(0)
x["payment_sum"]=x["payment_sum"].fillna(0)
x["reporting_lag_days"]=(x["reported_on"]-x["loss_date"]).dt.days
x["settlement_ratio"]=x["paid_total"]/x["claim_amount"]

# Executive KPIs
print("Claims:",len(x))
print("Claim amount:",x.claim_amount.sum())
print("Paid:",x.paid_total.sum())
print("Open reserve:",x.reserve_amount.sum())
print("Denial rate:",x.status.eq("denied").mean())
print("Paid-claim settlement ratio:",
      x.loc[x.status.eq("paid"),"paid_total"].sum() /
      x.loc[x.status.eq("paid"),"claim_amount"].sum())

# Segmentation
for col in ["peril","loss_state","coverage","credit_band","body_type"]:
    print("\n",col)
    print(x.groupby(col).agg(
        claims=("claim_id","count"),
        claim_amount=("claim_amount","sum"),
        paid=("paid_total","sum"),
        avg_claim=("claim_amount","mean")
    ).sort_values("claim_amount",ascending=False))

# Example visualization
x.groupby("peril")["claim_amount"].sum().sort_values().plot(kind="barh")
plt.title("Claim amount by peril")
plt.tight_layout()
plt.show()
