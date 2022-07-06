# Single or multiple clusters?
Created: 2022-07-05, 18:07

Cloud deployments of Kubernetes clusters can be expensive.  AWS [[#^eks-pricing|pricing]], for instance, currently shows that every cluster we run costs 10¢ per hour, which does not include any of the instances required to do actual work with the cluster.  Tests show that `t3.small` is the smallest instance that can run the required deployments, which [[#^aws-on-demand-pricing|currently]] stands at around 2¢ per hour.  This is a base price of roughly $87 per month—that's before we do any work and with a fairly minimal set of [[Common add-ons|add-ons]].

Individual projects are unlikely to have such high resource requirements as to justify the cost of a Kubernetes cluster; but if many projects can be served by a single cluster, the cost amortization makes sense.

The approach will be to deploy different projects into their own [[Namespaces|namespace]].  This will provide a separation between different projects' resources, while gaining the benefit of only having to maintain a single cluster's worth of system services.

Multiple clusters may be deployed to provide different environments—e.g., `staging` and `production`—which can allow for experimentation without threatening externally-visible resources.

## Links/Tags/References
1. https://learnk8s.io/how-many-clusters
2. https://aws.amazon.com/eks/pricing/ ^eks-pricing
3. https://aws.amazon.com/ec2/pricing/on-demand/ ^aws-on-demand-pricing