clearvars

m = 2;
n = 4;


options.dim = 3;
options.origin = 1;

[data] = generate_mic_rig(m,n,options);

D = data.d;

Cm = [-ones(1,m*2-1);eye(m*2-1)];
Cn = [-ones(1,n-1);eye(n-1)];

DD = Cm'*D.^2*Cn;

[uu,ss,vv] = svd(DD);

R = (uu*ss)';
S = vv';

Rt = [zeros(3,1) R];
St = [zeros(3,1) S];
St = St/(-2);
Rt = Rt;



Lgt = (R*inv(data.r(:,2:4)))';
Lgt = data.r(:,1:4)/Rt;
Lgt = inv(Lgt');



Hgt = inv(Lgt'*Lgt);
bgt = inv(Lgt)*data.s(:,1);

xx = inv(Lgt')*Rt;
yy = Lgt*(St+repmat(bgt,1,size(St,2)));

xx - data.r
yy - data.s

gt = [Hgt(1) Hgt(2) Hgt(3) Hgt(5) Hgt(6) Hgt(9) bgt(:)' 1/det(Hgt)]';


S = -S/2;

E = eye(10);
one = multipol(1,zeros(10,1));
zero = multipol(0,zeros(10,1));

D2 = D.^2;

for i = 1:10
    xv(i) = multipol(1,E(:,i));
end

H = [xv(1) xv(2) xv(3);
     xv(2) xv(4) xv(5);
     xv(3) xv(5) xv(6)];
b = [xv(7) xv(8) xv(9)]';

detH = detv(H);
adH = adjv(H);
if 1
R = ceil(20*randn(size(R)));
S = ceil(20*randn(size(R)));
D2 = ceil(20*rand(size(D2)));
l  = ceil(10*rand);;
data.l = ceil(10*rand);
end
eqs(1) = detv(H)*D2(1,1) - b'*adH*b;

k = 2;
for i = 1:n-1
    eqs(k) = detv(H)*(D2(1,i+1) - D2(1,1)) - S(:,i)'*adH*S(:,i) - 2*b'*adH*S(:,i);
    k      = k + 1;
end

for i = 1:2*m-1
    eqs(k) = (D2(i+1,1) - D2(1,1)) - R(:,i)'*H*R(:,i) + 2*b'*R(:,i);
    k      = k + 1;
end

eqs(k) = R(:,1)'*H*R(:,1) - data.l^2;

eqs(k+1) = R(:,2)'*H*R(:,2) - 2*R(:,2)'*H*R(:,3) + R(:,3)'*H*R(:,3) - data.l^2; 

eqs(k+2) = detH*xv(10) - 1;

eqs2m2(eqs(1:end),'eqsorg.m2');


%%
C = polynomials2matrix(eqs);



for i = 1:length(eqs)
    eqs(i) = eqs(i)/norm(C(i,:));
    
    [ccc,mmm{i}] = polynomials2matrix(eqs(i));
    mmm{i}       = monvec2matrix(mmm{i});
end


%%
[C,mon] = polynomials2matrix(eqs(end-5:end-1));
mm      = monvec2matrix(mon);

rrid = [1:4,9];
mmid = setdiff(1:9,rrid);

C = C(:,[rrid,[mmid,10]]);
mm = mm(:,[rrid,[mmid,10]]);

C = C(:,1:5)\C;

% C(:,6:end) = ceil(randn(size(C(:,6:end)))*20);
% C(5,[6,7]) = 0;

% C(1:5,1:5) = eye(5);

eqsnew = matrix2polynomials(C(:,6:end),[mm(mmid,6:end);zeros(1,5)]);

for i = 1:5
    yv(rrid(i)) = -eqsnew{i};
end

E = eye(5);
for i = 1:length(mmid)
    yv(mmid(i)) = multipol(1,E(:,i));
end

Hn = [yv(1) yv(2) yv(3);
      yv(2) yv(4) yv(5);
      yv(3) yv(5) yv(6)];
bn = [yv(7); yv(8); yv(9)];

adHn = adjv(Hn);
detHn = detv(Hn);

eqsn(1) = detHn*D2(1,1) - bn'*adHn*bn;

k = 2;
for i = 1:n-1
    eqsn(k) = detHn*(D2(1,i+1) - D2(1,1)) - S(:,i)'*adHn*S(:,i) - 2*bn'*adHn*S(:,i);
    k      = k + 1;
end

eqsn(k) = detHn*multipol(1,E(:,end))-1;



C = polynomials2matrix(eqsn);

eqs2m2(100000*eqsn,'eqs.m2');


for i = 1:length(eqsn);
    eqsn(i) = eqsn(i)/norm(C(i,:));
end

gtn = [gt(mmid);1/det(Hgt)];

evaluate(eqsn,gtn)

C = polynomials2matrix(eqsn);
for i = 1:length(eqsn)
    eqsn(i) = eqsn(i)/norm(C(i,:));
    
    [ccc,mmmm{i}] = polynomials2matrix(eqsn(i));
    mmmm{i}       = monvec2matrix(mmmm{i});
end
if 0
%%
settings.basis_size = 30;
settings.dim = 12;
settings.action_variable = 1;


eqs3 = generate_equations(eqsn,2);

C = polynomials2matrix(eqs3);
size(C)
[sols,stats] = polysolve(eqs3,settings);

stats

[err,err_list]  = evaluate_solutions(sols,gtn,settings);

[err,mid] = min(err_list);

[sols(:,mid) gtn]
end