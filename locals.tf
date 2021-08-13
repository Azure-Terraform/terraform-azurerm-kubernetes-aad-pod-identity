locals = {
    ##
    # If CRDs are installed and we are going to create AzureIdentity right away
    #  set a pause time between installation of pod identity and the creation
    #  of the AzureIdentity.  Otherwise there is a chance of failure.
    identity_creation_quiessence_time_in_secs = (var.install_crds and var.identities != null) ? 30 : 0
}