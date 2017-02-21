function [ c3 ] = my_c3_est(x, K , M, L )
%my_c3_est Estimation of 3rd order cummulants using indirect method
for i=1:K
    X(i,:)=x((i-1)*M+1:i*M);
    m=mean(X(i,:));
    X(i,:)=X(i,:)- m;
    for m=-L:L
        for n=-L:L
            s1=max([0 -m -n]);
            s2=min([M-1 M-1-m M-1-n]);
            summ=0;
            for l=s1:s2
                summ=summ+X(i,l+1)*X(i,l+m+1)*X(i,l+n+1);
            end
            r(i,m+L+1,n+L+1)=summ;
        end
    end
end

for m=-L:L
    for n=-L:L
        summ=0;
        for i=1:K
            summ=summ+r(i,m+L+1,n+L+1);
        end
        c3(m+L+1,n+L+1)=summ/K;
    end
end

end

