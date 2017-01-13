
cdef long long findzstate(basis_type * A,long long N, state_type s):
	cdef state_type  A_1
	cdef long long bmin, bmax, b

	bmin = 0
	bmax = N-1
	while (bmin <= bmax):
		b = (bmin + bmax)/2
		A_1 = A[b]
		if ( A_1 < s ):
			bmin = b + 1
		elif ( A_1 > s ):
			bmax = b - 1
		else:
			return b

	return -1


cdef void RefState_P_template(bitop fliplr,state_type s,int L,basis_type * R):
	cdef state_type t

	R[0] = s
	R[1] = 0


	t = fliplr(s,L)
	if t < s:
		R[0] = t
		R[1] = 1

	return











cdef void RefState_Z_template(bitop fliplr,state_type s,int L,basis_type * R):
	R[0] = s
	R[1] = 0

	cdef state_type t
	t = flip_all(s,L)
	if t < s:
		R[0] = t
		R[1] = 1

	return




cdef void RefState_ZA_template(bitop flip_sublat_A,state_type s,int L,basis_type * R):
	R[0] = s
	R[1] = 0

	cdef state_type t
	t = flip_sublat_A(s,L)
	if t < s:
		R[0] = t
		R[1] = 1

	return


cdef void RefState_ZB_template(bitop flip_sublat_B,state_type s,int L,basis_type * R):
	R[0] = s
	R[1] = 0

	cdef state_type t
	t = flip_sublat_B(s,L)
	if t < s:
		R[0] = t
		R[1] = 1

	return


cdef void RefState_ZA_ZB_template(bitop flip_sublat_A,bitop flip_sublat_B,bitop flip_all,state_type s,int L,basis_type * R):
	R[0] = s
	R[1] = 0
	R[2] = 0

	cdef state_type t, r
	r = s

	t = flip_sublat_A(s,L)
	if t < r:
		r = t
		R[1] = 1
		R[2] = 0

	t = flip_sublat_B(s,L)
	if t < r:
		r = t
		R[1] = 0
		R[2] = 1

	t = flip_all(s,L)
	if t < r:
		r = t
		R[1] = 1
		R[2] = 1

	R[0] = r
	return


cdef void RefState_PZ_template(bitop fliplr,bitop flip_all,state_type s,int L, basis_type * R):
	cdef state_type t

	R[0] = s
	R[1] = 0


	t = fliplr(s,L)
	t = flip_all(t,L)
	if t < s:
		R[0] = t
		R[1] = 1

	return







cdef void RefState_P_Z_template(bitop fliplr,bitop flip_all,state_type s,int L, basis_type * R):
	cdef state_type t,r

	R[0] = s
	R[1] = 0
	R[2] = 0

	r = s
	t = fliplr(s,L)
	if t < r:
		r = t
		R[1] = 1
		R[2] = 0


	t = flip_all(s,L)
	if t < r:
		r = t
		R[1] = 0
		R[2] = 1



	t = fliplr(s,L)
	t = flip_all(t,L)
	if t < r:
		r = t
		R[1] = 1
		R[2] = 1

	R[0] = r

	return



cdef void RefState_T_template(shifter shift,state_type s,int L,int T,basis_type * R):
	cdef int i
	cdef state_type r,t

	r = s
	t = s
	l = 0

	for i in range(1,L/T+1):
		t=shift(t,-T,L)
		if t < r:
			r=t; l=i;

	R[0] = r
	R[1] = l

	return





cdef void RefState_T_Z_template(shifter shift,bitop flip_all,state_type s,int L,int T,basis_type * R):
	cdef int i,l,g
	cdef state_type r,t

	r = s
	t = s

	l = 0
	g = 0

	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; g=0;

	t = flip_all(s,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; g=1;


	R[0] = r
	R[1] = l
	R[2] = g

	return



cdef void RefState_T_ZA_template(shifter shift,bitop flip_sublat_A,state_type s,int L,int T,basis_type * R):
	cdef int i,l,gA
	cdef state_type r,t

	r = s
	t = s

	l = 0
	gA = 0

	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; gA=0;

	t = flip_sublat_A(s,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; gA=1;


	R[0] = r
	R[1] = l
	R[2] = gA

	return


cdef void RefState_T_ZB_template(shifter shift,bitop flip_sublat_B,state_type s,int L,int T,basis_type * R):
	cdef int i,l,gB
	cdef state_type r,t

	r = s
	t = s

	l = 0
	gB = 0

	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; gB=0;

	t = flip_sublat_B(s,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; gB=1;


	R[0] = r
	R[1] = l
	R[2] = gB

	return


cdef void RefState_T_ZA_ZB_template(shifter shift,bitop flip_sublat_A,bitop flip_sublat_B,flip_all,state_type s,int L,int T,basis_type * R):
	cdef int i,l,gA,gB
	cdef state_type r,t

	r = s
	t = s

	l = 0
	gA = 0
	gB = 0
	
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; gA=0;gB=0;

	t = flip_sublat_A(s,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; gA=1;gB=0;

	t = flip_sublat_B(s,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; gA=0;gB=1;

	t = flip_all(s,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; gA=1;gB=1;


	R[0] = r
	R[1] = l
	R[2] = gA
	R[3] = gB

	return



cdef void RefState_T_P_template(shifter shift,bitop fliplr,state_type s,int L,int T,basis_type * R):
	cdef int i,l,q
	cdef state_type r,t

	r = s
	t = s

	l = 0
	q = 0

	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; q=0;

	t = fliplr(s,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; q=1;


	R[0] = r
	R[1] = l
	R[2] = q

	return












cdef void RefState_T_PZ_template(shifter shift,bitop fliplr,bitop flip_all,state_type s,int L,int T,basis_type * R):
	cdef int i
	cdef state_type r,t,l,qg

	r = s
	t = s

	l = 0
	qg = 0

	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; qg=0;

	t = fliplr(s,L)
	t = flip_all(t,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; qg=1;


	R[0] = r
	R[1] = l
	R[2] = qg

	return











cdef void RefState_T_P_Z_template(shifter shift,bitop fliplr,bitop flip_all,state_type s,int L,int T,basis_type * R):
	cdef int i,l,q,g
	cdef state_type r,t

	r = s
	t = s

	l = 0
	q = 0
	g = 0
	
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; q=0;g=0;

	t = fliplr(s,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; q=1;g=0;

	t = flip_all(s,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; q=0;g=1;

	t = fliplr(s,L)
	t = flip_all(t,L)
	for i in range(1,L/T+1):
		t = shift(t,-T,L)
		if t < r:
			r=t; l=i; q=1;g=1;


	R[0] = r
	R[1] = l
	R[2] = q
	R[3] = g

	return

