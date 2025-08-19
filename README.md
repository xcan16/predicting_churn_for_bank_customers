# Customer Churn Prediction for a Bank

##  Project Overview
This project predicts **customer churn** in a retail bank dataset using machine learning.  
The notebook demonstrates a full end-to-end workflow:  
- Exploratory Data Analysis (EDA)  
- Feature preprocessing with a **scikit-learn Pipeline**  
- Model training with **XGBoost**  
- **Threshold optimization** (Precision–Recall, F1-based)  
- Model evaluation with **ROC-AUC, confusion matrix, classification report**  
- Interpretability with **SHAP values (plots + table)**  
- Model saving & reusability with **joblib**  

---

##  Key Results
- **ROC-AUC**: ~0.84  
- **Best threshold (F1)**: ~0.63  
- **Test accuracy**: ~85%  
- **Top churn drivers** (by SHAP importance):  
  1. Age  
  2. NumOfProducts  
  3. Balance  
  4. IsActiveMember  
  5. EstimatedSalary  

---

##  Repository Structure
- `Predicting_Churn_for_Bank_Customers.ipynb` → Main notebook (EDA + Modeling + SHAP)  
- `churn_model.pkl` → Saved pipeline model (ready for inference)  
- `Churn_Modelling.csv` → Dataset (if license allows to upload, otherwise provide dataset link)  

---

##  Visual Highlights
### ROC Curve
*(example plot)*  
![ROC Curve](images/roc_curve.png)  

### SHAP Feature Importance
*(example plot)*  
![SHAP Bar](images/shap_importance.png)  

*(Tip: save your plots under `/images` folder and link here)*  

---

##  Next Steps
- Deploy the trained model via **Flask/FastAPI** for real-time predictions.  
- Experiment with alternative models (**LightGBM, CatBoost**) and compare.  
- Tune hyperparameters further with **cross-validation**.  

---

##  Tech Stack
- Python, Pandas, NumPy  
- Scikit-learn, XGBoost  
- SHAP, Matplotlib, Seaborn  

---
##  Author
Developed by **Samet Can Özden**  
Email: xcanozden@gmail.com  
