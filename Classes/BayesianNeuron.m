classdef BayesianNeuron < Neuron
    
    properties
        scaling 
        resetcondition
        resetfunction
        threshold
        resetv
    end
    
    methods
        function bn = BayesianNeuron(vars)
            if ~isa(vars,'BayesianNeuronVars')
                error('choose BayesianNeuronVars object')
            end
            bn = bn@Neuron(vars);
            bn.reset = true;
            bn.threshold=bn.vars.eta/2;
            bn.resetv=bn.vars.eta;
        end

    end
    
    methods (Static)
        
        %% Bayesian currents
        function ih = Ihbay(P0, V)
            if length(V)==1
                if V<0
                    ih=(1-P0).*(exp(-V)-1+V)-P0.*(exp(V)-1-V);
                else
                    ih=0;
                end
            else 
                ih = zeros(length(V),1);
                for n=1:length(V)
                    if V(n)<0
                        ih(n)=(1-P0).*(exp(-V(n))-1+V(n))-P0.*(exp(V(n))-1-V(n));
                    else
                        ih(n)=0;
                    end
                end
            end
        end
        function iag = Iadapbay(P0, G)
            if length(G)==1
                if G>0
                    iag=P0.*(exp(-G)-1)+(1-P0).*(exp(G)-1);
                else
                    iag=0;
                end
            else
                iag = zeros(length(G),1);
                for n=1:length(G)
                    if G(n)>0
                        iag(n)=P0.*(exp(-G(n))-1)+(1-P0).*(exp(G(n))-1);
                    else
                        iag(n)=0;
                    end
                end
            end
        end
        
        %% rheobase
        function rb = rheo_bay(bn)
            rb = bn.vars.theta+bn.vars.ron*(exp(bn.vars.eta/2)-1)-bn.vars.roff*(exp(-bn.vars.eta/2)-1);
        end
    end 
end

