# Password-based ATO Mitigation using Timing and Typing Pattern

This repository contains the complete project for user authentication based on typing patterns on mobile devices, as detailed in the thesis **"Password-based ATO Mitigation using Timing and Typing Pattern"**. The project includes the research report, iOS application code, data collection scripts, machine learning models, and results analysis.

## Table of Contents

- [Introduction](#introduction)
- [Data Collection](#data-collection)
- [Models](#models)
- [Results](#results)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This project aims to authenticate users based on their unique typing patterns on mobile devices. By collecting touch and motion data during typing, the system classifies users as genuine or imposters. The key components of the project are:

- **iOS Application**: An app to collect touch and motion data.
- **Data Collection**: Scripts and methodologies for gathering and storing data.
- **Machine Learning Models**: RNN and LSTM models for user classification.
- **Results Analysis**: Evaluation and visualization of model performance.

## Data Collection

The data collected from the iOS app includes:

- **Touch Data**: Radius, pressure, coordinates, and time intervals.
- **Motion Data**: Accelerometer and gyroscope readings, device orientation, and rotation rates.

These features are critical for distinguishing between genuine users and imposters.

## Models

### Recurrent Neural Network (RNN)

The RNN model is designed to process sequential data, such as typing patterns. It includes three layers with dropout and batch normalization to reduce overfitting.

### Long Short-Term Memory (LSTM)

The LSTM model, a type of RNN, addresses the vanishing gradient problem, making it more effective for long-term dependencies in sequential data.

### Training and Evaluation

The models are trained and evaluated using the collected data. The evaluation metrics include confusion matrices and ROC curves to visualize performance.

## Results

The results of the project demonstrate the effectiveness of the LSTM model in user classification. Here are the key findings:

- **RNN Classifier**:
  - Testing Accuracy: 75%
  - Confusion Matrix: Showed significant misclassifications, indicating lower reliability.
  - ROC Curves: Varied performance across different users, with some users showing better true positive rates than others.

- **LSTM Classifier**:
  - Testing Accuracy: Higher than the RNN model, indicating better overall performance.
  - Confusion Matrix: Improved accuracy with fewer misclassifications compared to the RNN model.
  - ROC Curves: Consistently better true positive rates across all users, demonstrating the model's robustness.

## Contributing

Contributions are welcome! Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Commit your changes and push the branch.
4. Open a pull request describing your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Feel free to explore the repository and use the provided tools and models for further research and development in user authentication based on typing patterns. For any questions or issues, please open an issue or contact the repository maintainers.

---

[GitHub Repository](https://github.com/aliabduljabbar/MS-Thesis)
