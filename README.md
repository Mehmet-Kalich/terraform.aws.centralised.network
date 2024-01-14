# terraform.aws.centralised.network
In the landscape of cloud network architecture, for most engineers, the conventional approach to provisioning internet access for their AWS hosted applications is to allow individual workload accounts (e.g development, user acceptance testing, production or “DEV, UAT, PRD”) to manage their own respective network resources. As a result, each account within the organisation manages their own network intricacies and internet access. This repo allows you to configure a fortified and centralized network account within AWS through IaC principles using Terraform to remove the complexities of juggling network resources across multiple accounts.

The problem with the conventional approach…

![image](https://github.com/Mehmet-Kalich/terraform.aws.centralised.network/assets/86363079/bcbf9abb-a196-4375-82aa-66b8f1e9d4bf)

In a small, straightforward AWS networks, delegating the responsibility of provisioning network resources and managing internet access to a single workload account is manageable. Private services utilise the designated private subnet, which is configured with a route table directing outbound traffic to a NAT gateway that we have situated in a public subnet. The NAT gateway, in turn, facilitates the translation of private IP addresses to public IP addresses before the egress traffic is directed through the Internet Gateway and out into the internet - the exact same is done in reverse with incoming traffic. Simple enough right? For AWS accounts used for testing, labs or even very small organisations, this network architecture is the most logical and straightforward. But what about when the size of our organisation and number of workload accounts increase?

![image](https://github.com/Mehmet-Kalich/terraform.aws.centralised.network/assets/86363079/26f88703-15c7-4b59-afd3-c7a36b2c50ea)

As you can see, as we begin to scale our workload accounts over several new AWS accounts, the complexity of our network architecture quickly becomes more apparent. The reusing of internet gateway and NAT related resources not only introduces additional costs, but also increases the number of potential attack vectors within our organisation alongside hindering the ability to maintain a solid set of network compliance standards.

While managing three separate workload accounts may still be manageable, the complexity  increases even more dramatically as we add 5, 10, 20 accounts or more to our organisational network. With each new addition, if there is a need to go beyond the VPC, internet gateway, NAT and subnet resources and provision CloudFront Distributions, WAFs, Network Firewalls, AWS Shield etc then the multiplication of these resources across each new account can lead us to a nightmare scenario. 

The endless administration overhead, increasing costs and constant attack surface reduction associated with a multi-workload network configuration can all be nullified if, instead, we utilise a more centralised network architecture strategy instead.

![image](https://github.com/Mehmet-Kalich/terraform.aws.centralised.network/assets/86363079/4ccc82c5-c1c8-4516-89b8-05a232ab52d7)

Now at first glance, this may seem more complex (and even a little bit bizarre compared to the coventional configuration), but what we see here is a fully centralised “Hub and Spoke” network topology. The centralised network allows us to inspect all of our traffic at one point, control ingress & egress traffic, reduce costs and reduce complexity by eliminating the need to maintain multiple network configurations in each individual workload account.

In order for us to achieve this architecture, there are 2 core services within this network topology that we need to understand:
1.	The use of Resource Access Manager (RAM) to facilitate the cross-account sharing the VPCS and & their respective subnets to workload accounts.
2.	The use of Transit Gateway as a means to route traffic to and from the Networking Account (the “Hub”) to the workload accounts (the “spokes”).

If we inspect the diagram above closer, the use of RAM can be seen in our creation of 3 separate VPCs (Dev, UAT, PRD), each with 3 separate subnets nested within each availability zone they reside in (AZ1, AZ2, AZ3). RAM enables us to share the DEV VPC and its subnets from the networking account with the DEV workload account, the UAT VPC and subnets with the UAT workload account, and the same for the PRD account. 

While services and applications from each of these workload accounts may have specific permissions to use and operate from within these shared resources, (and for all intents nad purposes may appear to be owned by the account they have been shared with) the workload acocunts do not have ownership to delete or modify these VPCs and subnets. 

This ownership is solely reserved for the Networking Account that these resources were created in. From a security and compliance perspective this is a massive win, as we have reduced the attack surface for potential cyber bad guys who hypothetically may have the potential to break into one of the workload accounts, but cannot do anything to the network architecture and resources that the entire organisation relies upon.

With regards to the 2nd core service in this centralised network architecture, the Transit Gateway (as seen to the right hand side of the diagram) is used as the physical hub for routing traffic between the ingress/egress Networking Account and each of the workload accounts. Traffic is routed to and from this Transit Gateway from each of the shared VPCs route tables, which forwards traffic towards the Networking Account from a specific shared subnet (named TGW Subnet) in each availability zone. 

This is what ingress and egress internet traffic looks like when utilising this centralised hub-spoke network architecture: (note: **NA** means the resource is within the Network Account, while **WA** means it is inside the workload account - DEV, UAT, PRD etc). 

Internet ➡️ internet gateway (**NA**) ➡️ public egress subnet (**NA**) ➡️ NAT Gateway(**NA**) ➡️ private egress subnet (**NA**) ➡️ transit gateway (**NA**) ➡️ PRD VPC (**WA**) ➡️ TGW Subnet (**WA**) ➡️ App Subnet (**WA**) ➡️ AWS resources utilising the app subnets. 

When these 2 core services are used in tandem, the 

