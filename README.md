# Basket Abandonment Detection

## Overview

This project is designed to detect and analyse instances of basket abandonment for the Google Merchandise Store. The project enables automatic detection of users who add items to their shopping carts but fail to complete the purchase, enabling automatic follow-up reminder emails.

## Key Components

- **Basket Abandonment Detection**: The system identifies cases of abandonment by checking whether items were added to the cart, ensuring no purchase occurred, and confirming that a certain time threshold has passed since the last activity.
  
- **Automation**: The detection process is set up to run every 15 minutes, ensuring that the data is consistently updated. This allows for timely email triggers via Adobe Campaign, reminding users about their abandoned carts.

- **Detailed Documentation**: The submission includes a comprehensive PDF document explaining the approach, data sources, and technical details of the project.

## Files and Directories

- **actionable_dataset.csv**: The final dataset containing the results of the basket abandonment detection for December 2020. This dataset is used to trigger follow-up actions.
  
- **cloud_case_study_submission.pdf**: The final report submitted as part of the application.

- **queries**: Contains SQL scripts used for data transformation and analysis, including:
    - **union_events.sql**: A script to combine event data for all days in December 2020.
    - **basket_abandonment.sql**: The core script that creates the actionable dataset used for detecting basket abandonment.
    -  **tests.sql**: Scripts to validate and test the actionable dataset.

- **latex**: Contains the LaTeX source files used to generate the PDF submission.

## How to Use

1. **Viewing the Submission**:
   - The `cloud_case_study_submission.pdf` file contains the detailed documentation of the project.
   
2. **Running the SQL Scripts**:
   - The SQL scripts located in the `queries` directory can be executed in BigQuery to generate the Actionable Dataset needed for basket abandonment detection.
   - The scripts should be scheduled in BigQuery to automate the detection process, ensuring up-to-date actionable datasets.

## Contact

For any questions or further information, please contact **Tom Dobson**.
