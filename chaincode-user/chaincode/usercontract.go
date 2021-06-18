package chaincode

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)



// SmartContract provides functions for managing an Asset
type UserContract struct {
	contractapi.Contract
}




// Asset describes basic details of what makes up a simple asset
type UserAccount struct {
	ID             string `json:"ID"`
	Name 		   string `json:"name"`
	Balance		   int 	  `json:"balance"`
}



// InitLedger adds a base set of assets to the ledger
func (s *UserContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	// 개인 피어 수 만큼 초기 세팅
	accounts := []UserAccount{
		{ID: "0", Name: "Hyeon Hee", Balance: 0},
		{ID: "1", Name: "Geum Bo", Balance: 0},
		{ID: "2", Name: "", Balance: 0},
		{ID: "3", Name: "", Balance: 0},
		{ID: "4", Name: "", Balance: 0},
		{ID: "5", Name: "", Balance: 0},
	}

	for _, account := range accounts {
		accountJSON, err := json.Marshal(account)
		if err != nil {
			return err
		}

		err = ctx.GetStub().PutState(account.ID, accountJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
	}

	return nil
}

func (s *UserContract) ReadAccount(ctx contractapi.TransactionContextInterface, id string) (*UserAccount, error) {
	accountJSON, err := ctx.GetStub().GetState(id)

	if err != nil {
		return nil, fmt.Errorf("failed to read world state: %v", err)
	}
	if accountJSON == nil {
		return nil, fmt.Errorf("the account %s does not exist", id)
	}

	var account UserAccount
	err = json.Unmarshal(accountJSON, &account)

	if err != nil {
		return nil, err
	}

	return &account, nil
}

// 은행에서 돈발행 
func (s *UserContract) UpdateAccount(ctx contractapi.TransactionContextInterface, id string, balance int) error {
	account, err := s.ReadAccount(ctx, id)
	if err != nil {
		return err
	}

	account.Balance = account.Balance + balance
	accountJSON, err := json.Marshal(account)
	if err != nil {
		return err
	}

	// 기록 

	return ctx.GetStub().PutState(id, accountJSON)	
}

// user 끼리의 돈전송 
func (s *UserContract) TransferBalanceUser(ctx contractapi.TransactionContextInterface, id string, rec string, price int) error {
	sender, err := s.ReadAccount(ctx, id)
	if err != nil {
		return err
	}
	receiver, err := s.ReadAccount(ctx, rec)
	if err != nil {
		return err
	}

	sBal := sender.Balance - price
	rBal := receiver.Balance + price
	if sBal < 0 {
		return fmt.Errorf("Lack of balance %s's Account", id)
	}
	sender.Balance = sBal
	receiver.Balance = rBal

	senderJSON, sErr := json.Marshal(sender)
	if sErr != nil {
		return sErr
	}
	receiverJSON, rErr := json.Marshal(receiver)
	if rErr != nil {
		return rErr
	}

	ctx.GetStub().PutState(id, senderJSON)
	ctx.GetStub().PutState(rec, receiverJSON)

	//기록 

	return nil	
}
