# Linkerd Docs 


### Installation (using linkerd-cli)


 - Use the following command to install linkerd-cli on your host: 

       curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh

 - To install linkerd on the cluster using linkerd-cli run the following commands:

       linkerd install --crds | kubectl apply -f -
       linkerd install | kubectl apply -f -

 - Run the following command to ensure that there were no issues with the linkerd installation on the cluster:

       linkerd check


**Note**: **Incase of fresh install make sure to re deploy the server and serverauthorization resources using the linkerd crds.** [**Configuration file for the same.**](https://codehub.mitsogo.com/dlp/services/dlp/-/blob/develop/.deployment/mtls/dlp_policies.yaml) 

 

### Replacing expired certificates


- Run the following command : 

       linkerd check --proxy 
  Check the linkerd-identity section of the output to validate any issues w.r.t. to certificates or trust anchors

- Incase of an expired certificate use the following command :

       linkerd upgrade --identity-issuer-certificate-file=./issuer-new.crt --identity-issuer-key-file=./issuer-new.key --identity-trust-anchors-file=./ca-new.crt  --force | kubectl apply -f -
   **Note: Ensure that you have generated your own root and issuer certificates before this step.** [**Follow these steps if not.**](https://linkerd.io/2.14/tasks/generate-certificates/#generating-the-certificates-with-step)

