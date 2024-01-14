# terraform.aws.centralised.network
In the landscape of cloud network architecture, for most engineers, the conventional approach to provisioning internet access for their AWS hosted applications is to allow individual workload accounts (e.g development, user acceptance testing, production or “DEV, UAT, PRD”) to manage their own respective network resources. As a result, each account within the organisation manages their own network intricacies and internet access. This repo allows you to configure a fortified and centralized network account within AWS through IaC principles using Terraform to remove the complexities of juggling network resources across multiple accounts.

The problem with the conventional approach…

![image](https://github.com/Mehmet-Kalich/terraform.aws.centralised.network/assets/86363079/bcbf9abb-a196-4375-82aa-66b8f1e9d4bf)
