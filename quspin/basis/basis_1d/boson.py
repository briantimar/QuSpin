from ._constructors import hcp_basis,hcp_ops
from ._constructors import boson_basis,boson_ops
from .base_1d import basis_1d
import numpy as _np




class boson_basis_1d(basis_1d):
	"""Basis for bosonic operators

	"""
	def __init__(self,L,Nb=None,nb=None,sps=None,**blocks):
		""" Intializes the `boson_basis_1d` object (basis for bosonic operators).

		Parameters
		----------

		L: int
			length of chain/number of sites

		Nb: int,list, optional
			number of bosons to put on chain, can be integer or list to specify one or more particle sectors.

		nb: float, optional
			density of bosons to put on chain

		sps: int, optional
			number of states to have per site (including 0 bosons)

		**blocks: optional
			extra keyword arguements which include:

				**a** (*int*) - specify how many sites to step for translation.

				**kblock** (*int*) - specify momentum block

				**pblock** (*int*) - specify parity block

			and the following which only work for hardcore bosons (sps=2):

				**cblock** (*int*) - specify particle hole symmetry block.

				**cAblock** (*int*) - specify particle hole of sublattice A symmetry block

				**cAblock** (*int*) - specify particle hole of sublattice B symmetry block

		Note
		----

		If Nb or nb are specified by default sps is set to the number of bosons on the lattice.	If sps is specified while Nb or nb are not, all particle sectors are filled up to the maximumal occupation. If Nb or nb and sps are specified, the finite boson basis is constructed with the local hilbert space restrited by sps.

		"""
		input_keys = set(blocks.keys())

		expected_keys = set(["_Np","kblock","cblock","cAblock","cBblock","pblock","pcblock","a","count_particles","check_z_symm","L"])
		wrong_keys = input_keys - expected_keys 
		if wrong_keys:
			temp = ", ".join(["{}" for key in wrong_keys])
			raise ValueError(("unexpected optional argument(s): "+temp).format(*wrong_keys))

		if sps is None:

			if Nb is not None:
				if nb is not None:
					raise ValueError("cannot use 'nb' and 'Nb' simultaineously.")

			elif nb is not None:
				if Nb is not None:
					raise ValueError("cannot use 'nb' and 'Nb' simultaineously.")

				Nb = int(nb*L)
			else:

				raise ValueError("expecting value for 'Nb','nb' or 'sps'")

			self._sps = Nb+1
		else:
			if Nb is not None:
				if nb is not None:
					raise ValueError("cannot use 'nb' and 'Nb' simultaineously.")

			elif nb is not None:
				Nb = int(nb*L)

			self._sps = sps


		if blocks.get("a") is None: # by default a = 1
			blocks["a"] = 1

		_Np = blocks.get("_Np")
		if _Np is None:
			blocks.pop("_Np")

		self._blocks = blocks
		
		pblock = blocks.get("pblock")
		zblock = blocks.get("cblock")
		zAblock = blocks.get("cAblock")
		zBblock = blocks.get("cBblock")

		if sps > 2 and any(type(block) is int for block in [zblock,zAblock,zBblock]):
			raise ValueError("particle hole symmetry doesn't exist with sps > 2.")

		if type(zblock) is int:
			del blocks["cblock"]
			blocks["zblock"] = zblock

		if type(zAblock) is int:
			del blocks["cAblock"]
			blocks["zAblock"] = zAblock

		if type(zBblock) is int:
			del blocks["cBblock"]
			blocks["zBblock"] = zBblock

		if (type(pblock) is int) and (type(zblock) is int):
			blocks["pzblock"] = pblock*zblock
			self._blocks["pcblock"] = pblock*zblock

		if (type(zAblock) is int) and (type(zBblock) is int):
			blocks["zblock"] = zAblock*zBblock
			self._blocks["cblock"] = zAblock*zBblock

		if self._sps <= 2:
			Imax = (1<<L)-1
			stag_A = sum(1<<i for i in range(0,L,2))
			stag_B = sum(1<<i for i in range(1,L,2))
			pars = _np.array([0,L,Imax,stag_A,stag_B]) # set sign to not be calculated
			self._operators = ("availible operators for boson_basis_1d:"+
								"\n\tI: identity "+
								"\n\t+: raising operator"+
								"\n\t-: lowering operator"+
								"\n\tn: number operator"+
								"\n\tz: c-symm number operator")

			self._allowed_ops = set(["I","+","-","n","z"])
			basis_1d.__init__(self,hcp_basis,hcp_ops,L,Np=Nb,_Np=_Np,pars=pars,**blocks)
		else:
			pars = (L,) + tuple(self._sps**i for i in range(L+1)) + (0,) # flag to turn off higher spin matrix elements for +/- operators
			
			self._operators = ("availible operators for ferion_basis_1d:"+
								"\n\tI: identity "+
								"\n\t+: raising operator"+
								"\n\t-: lowering operator"+
								"\n\tn: number operator"+
								"\n\tz: ph-symm number operator")

			self._allowed_ops = set(["I","+","-","n","z"])
			basis_1d.__init__(self,boson_basis,boson_ops,L,Np=Nb,_Np=_Np,pars=pars,**blocks)


	@property
	def blocks(self):
		return dict(self._blocks)

	def __type__(self):
		return "<type 'qspin.basis.boson_basis_1d'>"

	def __repr__(self):
		return "< instance of 'qspin.basis.boson_basis_1d' with {0} states >".format(self._Ns)

	def __name__(self):
		return "<type 'qspin.basis.boson_basis_1d'>"


	# functions called in base class:


	def _sort_opstr(self,op):
		if op[0].count("|") > 0:
			raise ValueError("'|' character found in op: {0},{1}".format(op[0],op[1]))
		if len(op[0]) != len(op[1]):
			raise ValueError("number of operators in opstr: {0} not equal to length of indx {1}".format(op[0],op[1]))

		op = list(op)
		zipstr = list(zip(op[0],op[1]))
		if zipstr:
			zipstr.sort(key = lambda x:x[1])
			op1,op2 = zip(*zipstr)
			op[0] = "".join(op1)
			op[1] = tuple(op2)
		return tuple(op)



	def _non_zero(self,op):
		opstr = _np.array(list(op[0]))
		indx = _np.array(op[1])
		if _np.any(indx):
			indx_p = indx[opstr == "+"].tolist()
			p = not any(indx_p.count(x) > 1 for x in indx_p)
			indx_p = indx[opstr == "-"].tolist()
			m = not any(indx_p.count(x) > 1 for x in indx_p)
			return (p and m)
		else:
			return True
		


	def _hc_opstr(self,op):
		op = list(op)
		# take h.c. + <--> - , reverse operator order , and conjugate coupling
		op[0] = list(op[0].replace("+","%").replace("-","+").replace("%","-"))
		op[0].reverse()
		op[0] = "".join(op[0])
		op[1] = list(op[1])
		op[1].reverse()
		op[1] = tuple(op[1])
		op[2] = op[2].conjugate()
		return self._sort_opstr(op) # return the sorted op.


	def _expand_opstr(self,op,num):
		op = list(op)
		op.append(num)
		return [tuple(op)]	


